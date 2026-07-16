# Engine-layer rendering benchmark (PageParsingService + LiquidParserWithCacheService).
# Deliberately does NOT re-measure raw Liquid parse/render throughput - the
# locomotivecms_steam project benchmarks that layer itself.
#
# Usage:
#   BENCHMARK_MONGO_DATABASE=locomotive_engine_benchmark \
#   RAILS_ENV=test bin/rails runner script/benchmarks/rendering_benchmark.rb \
#     --label before --json /private/tmp/engine-bench-before.json
#
# Metrics per scenario: wall-time p50/p95 (5 warmup + 30 measured runs) and
# allocations per run (GC.stat :total_allocated_objects). GC.start before each
# measured run, GC disabled only inside the timed block. Deterministic seed is
# created below in a dedicated database.
#
# Methodology notes:
# - page_parse_* scenarios measure the repeated backoffice parse path (the
#   editable elements already exist after warmup), not their initial creation.
# - liquid_cache_* scenarios measure parse + render: the warm variant therefore
#   exercises the cache read + Marshal.load + render path where snippet/section
#   loading happens at render time.

require 'json'

WARMUP = 5
RUNS   = 30

label = nil
json_path = nil
ARGV.each_with_index do |arg, i|
  label     = ARGV[i + 1] if arg == '--label'
  json_path = ARGV[i + 1] if arg == '--json'
end
abort 'Usage: ... --label <name> --json <path>' unless label && json_path

bench_db = ENV.fetch('BENCHMARK_MONGO_DATABASE', 'locomotive_engine_benchmark')
unless bench_db.include?('benchmark')
  abort "Refusing to run against #{bench_db.inspect}: the database gets dropped " \
        "and reseeded, so its name must contain 'benchmark'"
end

Mongoid.override_database(bench_db)
# Steam binds its own Mongo session from config.adapter (captured from mongoid.yml
# at boot); Mongoid.override_database does not reach it. The session is memoized
# lazily, so retargeting the adapter before the first steam query is safe here.
Locomotive::Steam.configuration.adapter[:database] = bench_db

actual_db = Locomotive::Site.collection.database.name
abort "Refusing to run: database override failed (got #{actual_db})" unless actual_db == bench_db
abort 'Refusing to run: steam adapter database not overridden' unless
  Locomotive::Steam.configuration.adapter[:database] == bench_db

# --- deterministic seed (fixed content, own database) -----------------------

[Locomotive::Site, Locomotive::Page, Locomotive::Snippet, Locomotive::Section,
 Locomotive::ContentType].each { |m| m.collection.drop }

def build_site(handle, cache_enabled)
  Locomotive::Site.create!(name: "Bench #{handle}", handle: handle,
                           locales: ['en'], cache_enabled: cache_enabled)
end

site       = build_site('bench', false)
cache_site = build_site('bench-cache', true)

home = site.pages.root.first
home.update!(raw_template: <<~LIQUID.strip)
  {% global_section nav, placement: 'top' %}{% section hero, id: 'home_hero', placement: 'top' %}
  <header>{% editable_text tagline %}Built for speed{% endeditable_text %}</header>
  {% block body %}{% editable_text intro %}Intro{% endeditable_text %}
    {% block body/aside %}{% editable_text ads %}Ads{% endeditable_text %}{% endblock %}
  {% endblock %}
  {% global_section footer, placement: 'bottom' %}
LIQUID

page_editables = site.pages.create!(
  title: 'Bench editables', slug: 'bench-editables', parent: home, published: true,
  raw_template: %({% extends parent %}{% block body %}{% editable_text top %}Hello{% endeditable_text %}{{ block.super }}{% endblock %}))

page_sections = site.pages.create!(
  title: 'Bench sections', slug: 'bench-sections', parent: home, published: true,
  raw_template: %({% extends parent %}{% block body %}{% section highlights %}{% sections_dropzone %}{% endblock %}))

cache_home = cache_site.pages.root.first
cache_home.update!(raw_template: 'HDR {% block main %}default{% endblock %} FTR')
Locomotive::Snippet.create!(site: cache_site, name: 'Bench snippet', slug: 'bench_snippet',
                            template: '<em>{% editable_text snippet_text %}from snippet{% endeditable_text %}</em>')
Locomotive::Section.create!(site: cache_site, name: 'Bench section', slug: 'bench_section',
                            template: '<h2>{{ section.settings.title }}</h2>',
                            definition: { name: 'bench_section',
                                          settings: [{ label: 'Title', id: 'title', type: 'text' }],
                                          blocks: [] })
cache_page = cache_site.pages.create!(
  title: 'Bench cached', slug: 'bench-cached', parent: cache_home, published: true,
  raw_template: %({% extends parent %}{% block main %}{% include 'bench_snippet' %} {% section bench_section %} inner{% endblock %}))

content_type = site.content_types.new(
  name: 'Articles', slug: 'articles',
  entry_template: '{{ entry.title }} - article',
  public_submission_title_template: 'New article: {{ entry.title }} on {{ site.name }}')
content_type.entries_custom_fields.build(label: 'Title', type: 'string')
content_type.save!
entry = content_type.entries.create!(title: 'Hello Bench')

# --- measurement harness -----------------------------------------------------

def measure(prepare: nil)
  samples = []
  (WARMUP + RUNS).times do |i|
    prepare&.call
    GC.start
    GC.disable
    begin
      a0 = GC.stat(:total_allocated_objects)
      t0 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      yield
      t1 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      allocs = GC.stat(:total_allocated_objects) - a0
    ensure
      GC.enable
    end
    samples << { ms: (t1 - t0) * 1000.0, allocs: allocs } if i >= WARMUP
  end
  ms     = samples.map { |s| s[:ms] }.sort
  allocs = samples.map { |s| s[:allocs] }.sort
  { p50_ms: ms[ms.size / 2].round(3), p95_ms: ms[(ms.size * 0.95).floor].round(3),
    allocs_p50: allocs[allocs.size / 2], runs: RUNS }
end

results = {}

# 1. PageParsingService#find_or_create_editable_elements (extends + nested blocks + editables).
#    Fresh service per run = the real backoffice request path (steam services build included).
results['page_parse_editables'] = measure(prepare: -> { page_editables.reload }) do
  Locomotive::PageParsingService.new(site, 'en').find_or_create_editable_elements(page_editables)
end

# 2. PageParsingService#find_all_elements (global_section + section + sections_dropzone).
results['page_parse_sections'] = measure(prepare: -> { page_sections.reload }) do
  Locomotive::PageParsingService.new(site, 'en').find_all_elements(page_sections)
end

# 3. LiquidParserWithCacheService - cold (parse + cache write + render) vs warm
#    (cache read + Marshal.load + render) on a snippet + section + extends page.
#    Rendering is part of the measurement on purpose: with the cache on, snippet
#    and section templates are loaded at render time, which is exactly the path
#    a marshaled template must still be able to walk.
#    The parser is built directly: the engine defers the cache-enabled parser
#    only inside request contexts (steam_adaptor services_hook), so
#    services.liquid_parser here would be the plain uncached parser.
services = Locomotive::Steam::Services.build_instance
services.set_site(cache_site)
services.locale = :en
parser = Locomotive::Steam::LiquidParserWithCacheService.new(
  services.current_site, services.parent_finder, services.snippet_finder, :en)
entity = services.repositories.page.build(cache_page.attributes.dup)
decorated = Locomotive::Steam::Decorators::TemplateDecorator.new(entity, :en, cache_site.default_locale)

render_registers = {
  services: services, page: decorated, locale: :en,
  file_system: Locomotive::Steam::Liquid::FileSystem.new(
    section_finder: services.section_finder, snippet_finder: services.snippet_finder)
}
render_template = lambda do |template|
  template.render(::Liquid::Context.new({}, {}, render_registers, true))
end

results['liquid_cache_cold'] = measure(prepare: -> { Rails.cache.clear }) do
  render_template.call(parser.parse(decorated))
end

Rails.cache.clear
parser.parse(decorated) # warm the cache once
cache_write_ok = !Rails.cache.read(parser.cache_key(decorated)).nil?
hit_render = render_template.call(parser.parse(decorated))
unless hit_render.include?('from snippet')
  abort 'cache-hit render did not include the snippet content; the cache path is broken'
end
results['liquid_cache_hit'] = measure do
  render_template.call(parser.parse(decorated))
end
results['liquid_cache_hit'][:cache_write_ok]   = cache_write_ok
results['liquid_cache_hit'][:cold_vs_warm] =
  (results['liquid_cache_cold'][:p50_ms] / results['liquid_cache_hit'][:p50_ms]).round(2)

# --- behaviour snapshots (engine's own Liquid surface) ------------------------

registers = { site: site, services: Locomotive::Steam::Services.build_instance }
snapshots = {
  entry_template: content_type.render_entry_template(
    ::Liquid::Context.new({}, { 'entry' => entry }, registers, true)),
  public_submission_title: content_type.public_submission_title(entry, {}),
  sections_structure: Locomotive::PageParsingService.new(site, 'en')
                        .find_all_elements(page_sections)[:sections],
  editables: Locomotive::PageParsingService.new(site, 'en')
               .find_or_create_editable_elements(page_editables)[:elements]
               .map { |(_, el)| [el.block, el.slug].compact.join('/') }.sort
}

# --- output --------------------------------------------------------------------

payload = {
  label: label,
  parser_class: parser.class.name,
  versions: {
    engine:  Locomotive::VERSION,
    rails:   Rails.version,
    steam:   Locomotive::Steam::VERSION,
    liquid:  Liquid::VERSION,
    mongoid: Mongoid::VERSION,
    ruby:    RUBY_VERSION,
    yjit:    defined?(RubyVM::YJIT) && RubyVM::YJIT.enabled?
  },
  scenarios: results,
  snapshots: snapshots
}

File.write(json_path, JSON.pretty_generate(payload))

puts format('%-22s %10s %10s %14s', 'scenario', 'p50 ms', 'p95 ms', 'allocs p50')
results.each do |name, r|
  puts format('%-22s %10.3f %10.3f %14d', name, r[:p50_ms], r[:p95_ms], r[:allocs_p50])
end
puts "cache_write_ok=#{cache_write_ok} cold_vs_warm=#{results['liquid_cache_hit'][:cold_vs_warm]}x"
puts payload[:versions].map { |k, v| "#{k}=#{v}" }.join(' ')
puts "json: #{json_path}"
