require 'spec_helper'

describe Locomotive::Snippet do

  it 'has a valid factory' do
    expect(FactoryGirl.build(:snippet)).to be_valid
  end

  # Validations ##

  %w{site name template}.each do |field|
    it "validates presence of #{field}" do
      template = FactoryGirl.build(:snippet, field.to_sym => nil)
      expect(template).to_not be_valid
      expect(template.errors[field.to_sym]).to eq(["can't be blank"])
    end
  end

  describe '#update_templates' do

    before :each do
      @site    = FactoryGirl.create(:site, subdomain: 'omg')
      @snippet = FactoryGirl.create(:snippet, site: @site, slug: 'my_test_snippet', template: 'a testing template')
    end

    context 'with a normal top level snippet' do

      before :each do
        @page = FactoryGirl.create(:page, site: @site, slug: 'my_page_here', raw_template: "{% include 'my_test_snippet'  %}")
      end

      it 'updates templates with the new snippet template' do
        @snippet.update_attributes(template: 'a new template')
        expect(Locomotive::Page.find(@page.id).render({})).to eq('a new template')
      end

    end

    context 'for snippets inside of a block' do

      before :each do
        @page = FactoryGirl.create(:page, site: @site, slug: 'my_page_here', raw_template: "{% block main %}{% include 'my_test_snippet'  %}{% endblock %}")
      end

      it 'updates templates with the new snippet template' do
        @snippet.update_attributes(template: 'a new template')
        expect(Locomotive::Page.find(@page.id).render({})).to eq('a new template')
      end

    end

    context 'for snippets inside a snippet' do
      before :each do
        @nested_snippet = FactoryGirl.create(:snippet, site: @site, slug: 'my_nested_test_snippet', template: "{% include 'my_test_snippet' %}")
        @page = FactoryGirl.create(:page, site: @site, slug: 'my_page_here', raw_template: "{% include 'my_nested_test_snippet' %}")
      end

      it 'renders the nested snippet' do
        expect(Locomotive::Page.find(@page.id).render({})).to eq('a testing template')
      end

      it 'updates parent snippets with the new snippet template' do
        @snippet.update_attributes(template: 'a new template')
        expect(Locomotive::Page.find(@page.id).render({})).to eq('a new template')
      end

      it 'when the parent snippet is updated child snippets are rendered correctly' do
        @nested_snippet.update_attributes(template: "hello {% include 'my_test_snippet' %}")
        expect(Locomotive::Page.find(@page.id).render({})).to eq('hello a testing template')
      end
    end

    context '#i18n' do

      before :each do
        Mongoid::Fields::I18n.with_locale(:fr) do
          @snippet = FactoryGirl.create(:snippet, site: @site, slug: 'my_localized_test_snippet', template: 'a testing template')
          @page = FactoryGirl.create(:page, site: @site, slug: 'my_localized_test_snippet', raw_template: "{% block main %}{% include 'my_localized_test_snippet' %}{% endblock %}")
        end
      end

      it 'returns the snippet dependencies depending on the UI locale' do
        Mongoid::Fields::I18n.with_locale(:fr) { expect(@page.snippet_dependencies).to_not be_empty }
        Mongoid::Fields::I18n.with_locale(:en) { expect(@page.snippet_dependencies).to eq(nil) }
      end

      it 'updates the templates with the new snippet' do
        Mongoid::Fields::I18n.with_locale(:fr) do
          @snippet.update_attributes(template: 'a new template')
          expect(Locomotive::Page.find(@page.id).render({})).to eq('a new template')
        end
      end

    end

  end

end
