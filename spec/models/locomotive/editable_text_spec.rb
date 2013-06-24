require 'spec_helper'

describe Locomotive::EditableText do

  describe 'a simple case' do

    before(:each) do
      @site = FactoryGirl.create(:site)
      @home = @site.pages.root.first

      @home.update_attributes raw_template: "{% block body %}{% editable_text 'body' %}Lorem ipsum{% endeditable_text %}{% endblock %}"

      @sub_page_1 = FactoryGirl.create(:page, slug: 'sub_page_1', parent: @home, raw_template: "{% extends 'parent' %}")
      @sub_page_2 = FactoryGirl.create(:page, slug: 'sub_page_2', parent: @home, raw_template: "{% extends 'parent' %}")

      @sub_page_1_el = @sub_page_1.editable_elements.first

      @sub_page_1_1 = FactoryGirl.create(:page, slug: 'sub_page_1_1', parent: @sub_page_1, raw_template: "{% extends 'parent' %}")
    end

    describe 'properties' do

      it 'exists' do
        @sub_page_1.editable_elements.size.should == 1
      end

      it 'has a non-nil slug' do
        @sub_page_1.editable_elements.first.slug.should == 'body'
      end

      it 'has a default content at first' do
        @sub_page_1.editable_elements.first.default_content.should be_true
        @sub_page_1.editable_elements.first.content.should == 'Lorem ipsum'
      end

      it 'is still default when it gets modified by the exact same value' do
        @sub_page_1.editable_elements.first.content = 'Lorem ipsum'
        @sub_page_1.editable_elements.first.default_content.should be_true
      end

      it 'strips the content' do
        @sub_page_1.editable_elements.first.update_attribute :content, "   Lorem ipsum\n\n   "
        @sub_page_1.editable_elements.first.content.should == 'Lorem ipsum'
      end

    end

    describe 'locales' do

      it 'assigns the default locale' do
        @sub_page_1_el.locales.should == ['en']
      end

      it 'adds new locale' do
        ::Mongoid::Fields::I18n.with_locale 'fr' do
          page = Locomotive::Page.find(@home._id)
          page.editable_elements.first.content = 'Lorem ipsum (FR)'
          page.save
          page.editable_elements.first.locales.should == %w(en fr)
        end
      end

      it 'adds new locale within sub page elements' do
        ::Mongoid::Fields::I18n.with_locale 'fr' do
          @home.update_attributes title: 'Accueil', raw_template: "{% block body %}{% editable_text 'body' %}Lorem ipsum{% endeditable_text %}{% endblock %}"
          page = Locomotive::Page.find(@sub_page_1._id)
          page.editable_elements.first.content = 'Lorem ipsum (FR)'
          page.save
          page.editable_elements.first.locales.should == %w(en fr)
        end
      end

    end

    describe 'when modifying the raw template' do

      it 'can update its content from the raw template if the user has not modified it' do
        @home.update_attributes raw_template: "{% block body %}{% editable_text 'body' %}Lorem ipsum v2{% endeditable_text %}{% endblock %}"
        @home.editable_elements.first.default_content.should be_true
        @home.editable_elements.first.content.should == 'Lorem ipsum v2'
      end

      it 'does not touch the content if the user has modified it before' do
        @home.editable_elements.first.content = 'Hello world'
        @home.raw_template = "{% block body %}{% editable_text 'body' %}Lorem ipsum v2{% endeditable_text %}{% endblock %}"
        @home.save
        @home.editable_elements.first.default_content.should be_false
        @home.editable_elements.first.content.should == 'Hello world'
      end

    end

    describe '.editable?' do

      it 'is editable' do
        @sub_page_1_el.editable?.should be_true
      end

      it 'is not editable if the element is disabled' do
        @sub_page_1_el.disabled = true
        @sub_page_1_el.editable?.should be_false
      end

      it 'is not editable if it is a fixed one' do
        @sub_page_1_el.fixed = true
        @sub_page_1_el.editable?.should be_false
      end

      it 'is not editable if it does exist for the current locale' do
        ::Mongoid::Fields::I18n.with_locale 'fr' do
          @sub_page_1_el.editable?.should be_false
        end
      end

      it 'is among the editable elements of the page' do
        @sub_page_1.enabled_editable_elements.map(&:slug).should == %w(body)
      end

      it 'is not among the editable elements of the page if disabled' do
        @sub_page_1_el.disabled = true
        @sub_page_1.enabled_editable_elements.map(&:slug).should == []
      end

    end

    describe 'in sub pages level #1' do

      before(:each) do
        @sub_page_1.reload
        @sub_page_2.reload
      end

      it 'exists' do
        @sub_page_1.editable_elements.size.should == 1
        @sub_page_2.editable_elements.size.should == 1
      end

      it 'has a non-nil slug' do
        @sub_page_1.editable_elements.first.slug.should == 'body'
      end

      it 'does not have a content at first' do
        @sub_page_1_el.default_content.should be_true
        @sub_page_1_el.content.should == 'Lorem ipsum'
      end

    end

    describe 'in sub pages level #2' do

      before(:each) do
        @sub_page_1_1.reload
      end

      it 'exists' do
        @sub_page_1_1.editable_elements.size.should == 1
      end

      it 'has a non-nil slug' do
        @sub_page_1_1.editable_elements.first.slug.should == 'body'
      end

      it 'removes editable elements' do
        @sub_page_1_1.editable_elements.destroy_all
        @sub_page_1_1.reload
        @sub_page_1_1.editable_elements.size.should == 0
      end

    end

  end

  describe '"sticky" elements' do

    before(:each) do
      @site = FactoryGirl.create(:site)
      @home = @site.pages.root.first

      @home.update_attributes raw_template: "{% block body %}{% editable_text 'body', fixed: true %}Lorem ipsum{% endeditable_text %}{% endblock %}"
      @home_el = @home.editable_elements.first

      @sub_page_1 = FactoryGirl.create(:page, slug: 'sub_page_1', parent: @home, raw_template: "{% extends 'parent' %}")
      @sub_page_2 = FactoryGirl.create(:page, slug: 'sub_page_2', parent: @home, raw_template: "{% extends 'parent' %}")

      @sub_page_1_el = @sub_page_1.editable_elements.first
      @sub_page_2_el = @sub_page_2.editable_elements.first
    end

    it 'exists in sub pages' do
      @sub_page_1.editable_elements.size.should == 1
      @sub_page_2.editable_elements.size.should == 1
    end

    it 'is marked as fixed' do
      @sub_page_1_el.fixed?.should be_true
      @sub_page_2_el.fixed?.should be_true
    end

    it 'enables the default content when it just got created' do
      @sub_page_1_el.default_content?.should be_true
    end

    it 'disables the default content if the content changed' do
      @sub_page_1_el.content = 'Bla bla'
      @sub_page_1_el.default_content?.should be_false
    end

    it 'gets also updated when updating the very first element' do
      @home_el.content = 'Hello world'
      @home.save
      @sub_page_1.reload; @sub_page_1_el = @sub_page_1.editable_elements.first
      @sub_page_2.reload; @sub_page_2_el = @sub_page_2.editable_elements.first
      @sub_page_1_el.content.should == 'Hello world'
      @sub_page_2_el.content.should == 'Hello world'
    end

  end

end