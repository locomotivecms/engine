# encoding: utf-8

require 'spec_helper'

describe Locomotive::Liquid::Tags::LocaleSwitcher do

	let(:site) do
    FactoryGirl.build(:site, :locales => %w(en fr))
  end

  let(:page) do
  	site.pages.build.tap do |page|
  		page.stubs(:index?).returns(true)
  		page.stubs(:fullpath_translations).returns({ 'en' => 'index', 'fr' => 'index' })
  	end
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

  def render_tag(locale = 'en', options = nil)
    assigns					= { 'locale' => locale }
    registers       = { :site => site, :page => page }
    liquid_context  = ::Liquid::Context.new({}, assigns, registers)

    output = Liquid::Template.parse("{% locale_switcher #{options} %}").render(liquid_context)
    output.gsub(/\n\s{0,}/, '')
  end

end