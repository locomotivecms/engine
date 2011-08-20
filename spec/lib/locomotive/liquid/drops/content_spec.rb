require 'spec_helper'

describe Locomotive::Liquid::Drops::Content do

  before(:each) do
    @site = FactoryGirl.build(:site)
    content_type = FactoryGirl.build(:content_type)
    content_type.content_custom_fields.build :label => 'anything', :kind => 'string'
    content_type.content_custom_fields.build :label => 'published_at', :kind => 'date'
    @content = content_type.contents.build({
      :meta_keywords => 'Libidinous, Angsty',
      :meta_description => "Quite the combination.",
      :published_at => Date.today })
  end

  describe 'meta_keywords' do
    subject { render_template('{{ content.meta_keywords }}') }
    it { should == @content.meta_keywords }
  end

  describe 'meta_description' do
    subject { render_template('{{ content.meta_description }}') }
    it { should == @content.meta_description }
  end

  describe 'date comparaison' do

    describe 'older than' do
      subject { @content.published_at = 3.days.ago; render_template('{% if content.published_at < today %}In the past{% endif %}') }
      it { should == 'In the past' }
    end

    describe 'more recent than' do
      subject { @content.published_at = (Time.now + 1.days); render_template('{% if content.published_at > today %}In the future{% endif %}') }
      it { should == 'In the future' }
    end

    describe 'equality' do
      subject { render_template('{% if content.published_at == today %}Today{% endif %}') }
      it { should == 'Today' }
    end

  end

  def render_template(template = '', assigns = {})
    assigns = { 'content' => @content, 'today' => Date.today }.merge(assigns)
    Liquid::Template.parse(template).render(::Liquid::Context.new({}, assigns, { :site => @site }))
  end

end
