require 'spec_helper'

describe Locomotive::Liquid::Tags::Editable::Content do

  before :each do
    Locomotive::Liquid::Tags::Editable::Content.any_instance.stubs(:end_tag).returns(true)
  end

  context 'syntax' do

    it 'should have a valid syntax' do
      ["slug", "slug, inherit: true"].each do |markup|
        lambda do
          Locomotive::Liquid::Tags::Editable::Content.new('content', markup, ["{% content %}"], {})
        end.should_not raise_error
      end
    end

  end

  context 'output' do

    before :each do
      EditableElement.any_instance.stubs(:content).returns("test string")
    end

    context 'inheriting from a parent' do

      before :each do
        @parent = FactoryGirl.build(:page)
        @child = FactoryGirl.build(:page)

        @child.stubs(:parent).returns(@parent)
      end

      it 'should return the parents field if inherit is set' do
        @element = @parent.editable_elements.create(:slug => 'test')
        @child.stubs(:raw_template).returns("{% content test, inherit: true %}")
        template = Liquid::Template.parse(@child.raw_template)
        text = template.render!(liquid_context(:page => @child))
        text.should match /test string/
      end

      it 'should raise an exception if it cant find the field' do
        @child.stubs(:raw_template).returns("{% content test, inherit: true %}")
        template = Liquid::Template.parse(@child.raw_template)
        lambda do
          template.render!(liquid_context(:page => @child))
        end.should raise_error
      end

      after :each do
        @parent.editable_elements.destroy_all
      end

    end

    context 'reading from the same page' do

      before :each do
        @page = FactoryGirl.build(:page)
      end

      it 'should return the previously defined field' do
        @element = @page.editable_elements.create(:slug => 'test')
        @page.stubs(:raw_template).returns("{% content test %}")
        template = Liquid::Template.parse(@page.raw_template)
        text = template.render!(liquid_context(:page => @page))
        text.should match /test string/
      end

      it 'should raise an exception if it wasnt defined' do
        @page.stubs(:raw_template).returns("{% content test %}")
        template = Liquid::Template.parse(@page.raw_template)
        lambda do
          template.render!(liquid_context(:page => @page))
        end.should raise_error
      end

      after :each do
        @page.editable_elements.destroy_all
      end

    end

  end

  # ___ helpers methods ___ #

  def liquid_context(options = {})
    ::Liquid::Context.new({}, {},
    {
      :page => options[:page]
    }, true)
  end

end
