require 'spec_helper'

describe Locomotive::Liquid::Tags::Paginate do

  it 'has a valid syntax' do
    markup = "contents.projects by 5"
    lambda do
      Locomotive::Liquid::Tags::Paginate.new('paginate', markup, ["{% endpaginate %}"], {})
    end.should_not raise_error
  end

  it 'raises an error if the syntax is incorrect' do
    ["contents.projects by a", "contents.projects", "contents.projects 5"].each do |markup|
      lambda do
        Locomotive::Liquid::Tags::Paginate.new('paginate', markup, ["{% endpaginate %}"], {})
      end.should raise_error
    end
  end

  it 'paginates the collection' do
    template  = Liquid::Template.parse(default_template)
    text      = template.render!(liquid_context)

    text.should match /!Ruby on Rails!/
    text.should match /!jQuery!/
    text.should_not match /!mongodb!/

    text = template.render!(liquid_context(page: 2))

    text.should_not match /!jQuery!/
    text.should match /!mongodb!/
    text.should match /!Liquid!/
    text.should_not match /!sqlite3!/
  end

  it 'does not paginate if collection is nil or empty' do
    template = Liquid::Template.parse(default_template)

    lambda do
      template.render!(liquid_context(collection: nil))
    end.should raise_error

    lambda do
      template.render!(liquid_context(collection: PaginatedCollection.new))
    end.should raise_error
  end

  it 'keeps the original GET parameters' do
    context   = liquid_context(fullpath: '/products?foo=1&bar=1&baz=1')
    template  = Liquid::Template.parse(default_template)
    text      = template.render!(context)
    text.should match /\/products\?foo=1&bar=1&baz=1&page=2/
  end

  it 'does not include twice the page parameter' do
    context   = liquid_context(fullpath: '/products?page=1')
    template  = Liquid::Template.parse(default_template)
    text      = template.render!(context)
    text.should match /\/products\?page=2/
  end

  it 'respects the window_size option' do
    template  = Liquid::Template.parse(default_pagination_template('window_size: 10'))
    text      = template.render!(liquid_context(collection: PaginatedCollection.new((1..100).to_a)))

    text.should match /\/\?page=4/
    text.should match /\/\?page=10/
    text.should_not match /\/\?page=11/
  end

  # ___ helpers methods ___ #

  def liquid_context(options = {})
    ::Liquid::Context.new(
      {},
      {
      'projects'      => options.has_key?(:collection) ? options[:collection] : PaginatedCollection.new(['Ruby on Rails', 'jQuery', 'mongodb', 'Liquid', 'sqlite3']),
      'current_page'  => options[:page] || 1,
      'path'          => '/',
      'fullpath'      => options[:fullpath] || '/'
    }, {
      page:           FactoryGirl.build(:page)
    }, true)
  end

  def default_template
    "{% paginate projects by 2 %}
      {% for project in paginate.collection %}
        !{{ project }}!
      {% endfor %}
      {{ paginate.next.url }}
    {% endpaginate %}"
  end

  def default_pagination_template(options='')
    "{% paginate projects by 2 #{options} %}
      {% for project in paginate.collection %}
        !{{ project }}!
      {% endfor %}
      {{ paginate.next.url }}
      {{ paginate | default_pagination }}
    {% endpaginate %}"
  end

  class PaginatedCollection

    def initialize(collection)
      @collection = collection || []
    end

    def paginate(options = {})
      total_pages = (@collection.size.to_f / options[:per_page].to_f).to_f.ceil + 1
      offset = (options[:page] - 1) * options[:per_page]

      {
        collection:     @collection[offset..(offset + options[:per_page]) - 1],
        current_page:   options[:page],
        previous_page:  options[:page] == 1 ? 1 : options[:page] - 1,
        next_page:      options[:page] == total_pages ? total_pages : options[:page] + 1,
        total_entries:  @collection.size,
        total_pages:    total_pages,
        per_page:       options[:per_page]
      }
    end

    def each(&block)
      @collection.each(&block)
    end

    def method_missing(method, *args)
      @collection.send(method, *args)
    end

    def to_liquid
      self
    end
  end

end
