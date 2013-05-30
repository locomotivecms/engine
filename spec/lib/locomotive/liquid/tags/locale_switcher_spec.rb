# encoding: utf-8

require 'spec_helper'

describe Locomotive::Liquid::Tags::LocaleSwitcher do

  let(:site) do
    FactoryGirl.create(:site, locales: %w(en fr))
  end

  let(:page) do
    site.pages.where(slug: "index").first
  end

  let(:translated_page) do
    page = FactoryGirl.create(:page, title: "Hello", slug: "hello", site: site, parent: site.pages.where(slug: "index").first)
    ::Mongoid::Fields::I18n.with_locale(:fr) do
      page.update_attributes(title: "Bonjour")
    end
    page
  end

  it 'renders the switcher widget in the current locale' do
    html = render_tag
    html.should == '<div id="locale-switcher"><a href="/" class="en current">en</a> | <a href="/fr" class="fr">fr</a></div>'
  end

  it 'renders the switcher widget in another locale' do
    html = render_tag('fr')
    html.should == '<div id="locale-switcher"><a href="/" class="en">en</a> | <a href="/fr" class="fr current">fr</a></div>'
  end

  it 'uses a different sep' do
    html = render_tag('en', "sep: ' - '")
    html.should == '<div id="locale-switcher"><a href="/" class="en current">en</a> - <a href="/fr" class="fr">fr</a></div>'
  end

  it 'translates the label if specified' do
    html = render_tag('en', "label: 'locale'")
    html.should == '<div id="locale-switcher"><a href="/" class="en current">English</a> | <a href="/fr" class="fr">French</a></div>'
  end

  it "translates fullpaths" do
    html = render_tag('en', nil, translated_page)
    html.should == '<div id="locale-switcher"><a href="/hello" class="en current">en</a> | <a href="/fr/bonjour" class="fr">fr</a></div>'
  end

  def render_tag(locale = 'en', options = nil, specific_page = nil)
    assigns         = { 'locale' => locale }
    registers       = { site: site, page: specific_page || page }
    liquid_context  = ::Liquid::Context.new({}, assigns, registers)

    output = Liquid::Template.parse("{% locale_switcher #{options} %}").render(liquid_context)
    output.gsub(/\n\s{0,}/, '')
  end

end