# require 'spec_helper'

# describe Locomotive::EditableText do

#   describe 'a simple case' do

#     before(:each) do
#       @site = FactoryGirl.create(:site)
#       @home = @site.pages.root.first

#       @home.update_attributes raw_template: "{% block body %}{% editable_text 'body' %}Lorem ipsum{% endeditable_text %}{% endblock %}"

#       @sub_page_1 = FactoryGirl.create(:page, title: '1', slug: 'sub_page_1', parent: @home, raw_template: "{% extends 'parent' %}")
#       @sub_page_2 = FactoryGirl.create(:page, title: '2', slug: 'sub_page_2', parent: @home, raw_template: "{% extends 'parent' %}")

#       @sub_page_1_el = @sub_page_1.editable_elements.first

#       @sub_page_1_1 = FactoryGirl.create(:page, title: '1_1', slug: 'sub_page_1_1', parent: @sub_page_1, raw_template: "{% extends 'parent' %}")
#     end

#     describe 'properties' do

#       it 'exists' do
#         expect(@sub_page_1.editable_elements.size).to eq(1)
#       end

#       it 'has a non-nil slug' do
#         expect(@sub_page_1.editable_elements.first.slug).to eq('body')
#       end

#       it 'has a default content at first' do
#         expect(@sub_page_1.editable_elements.first.default_content).to eq(true)
#         expect(@sub_page_1.editable_elements.first.content).to eq('Lorem ipsum')
#       end

#       it 'is still default when it gets modified by the exact same value' do
#         @sub_page_1.editable_elements.first.content = 'Lorem ipsum'
#         expect(@sub_page_1.editable_elements.first.default_content).to eq(true)
#       end

#       it 'strips the content' do
#         @sub_page_1.editable_elements.first.update_attribute :content, "   Lorem ipsum\n\n   "
#         expect(@sub_page_1.editable_elements.first.content).to eq('Lorem ipsum')
#       end

#     end

#     describe 'locales' do

#       it 'assigns the default locale' do
#         expect(@sub_page_1_el.locales).to eq(['en'])
#       end

#       it 'adds new locale' do
#         ::Mongoid::Fields::I18n.with_locale 'fr' do
#           page = Locomotive::Page.find(@home._id)
#           page.editable_elements.first.content = 'Lorem ipsum (FR)'
#           page.save
#           expect(page.editable_elements.first.locales).to eq(%w(en fr))
#         end
#       end

#       it 'adds new locale within sub page elements' do
#         ::Mongoid::Fields::I18n.with_locale 'fr' do
#           @home.update_attributes title: 'Accueil', raw_template: "{% block body %}{% editable_text 'body' %}Lorem ipsum{% endeditable_text %}{% endblock %}"
#           page = Locomotive::Page.find(@sub_page_1._id)
#           page.editable_elements.first.content = 'Lorem ipsum (FR)'
#           page.save
#           expect(page.editable_elements.first.locales).to eq(%w(en fr))
#         end
#       end

#     end

#     describe 'when modifying the raw template' do

#       it 'can update its content from the raw template if the user has not modified it' do
#         @home.update_attributes raw_template: "{% block body %}{% editable_text 'body' %}Lorem ipsum v2{% endeditable_text %}{% endblock %}"
#         expect(@home.editable_elements.first.default_content).to eq(true)
#         expect(@home.editable_elements.first.content).to eq('Lorem ipsum v2')
#       end

#       it 'does not touch the content if the user has modified it before' do
#         @home.editable_elements.first.content = 'Hello world'
#         @home.raw_template = "{% block body %}{% editable_text 'body' %}Lorem ipsum v2{% endeditable_text %}{% endblock %}"
#         @home.save
#         expect(@home.editable_elements.first.default_content).to eq(false)
#         expect(@home.editable_elements.first.content).to eq('Hello world')
#       end

#     end

#     describe '.editable?' do

#       it 'is editable' do
#         expect(@sub_page_1_el.editable?).to eq(true)
#       end

#       it 'is not editable if the element is disabled' do
#         @sub_page_1_el.disabled = true
#         expect(@sub_page_1_el.editable?).to eq(false)
#       end

#       it 'is not editable if it is a fixed one' do
#         @sub_page_1_el.fixed = true
#         expect(@sub_page_1_el.editable?).to eq(false)
#       end

#       it 'is not editable if it does exist for the current locale' do
#         ::Mongoid::Fields::I18n.with_locale 'fr' do
#           expect(@sub_page_1_el.editable?).to eq(false)
#         end
#       end

#       it 'is among the editable elements of the page' do
#         expect(@sub_page_1.enabled_editable_elements.map(&:slug)).to eq(%w(body))
#       end

#       it 'is not among the editable elements of the page if disabled' do
#         @sub_page_1_el.disabled = true
#         expect(@sub_page_1.enabled_editable_elements.map(&:slug)).to eq([])
#       end

#     end

#     describe 'in sub pages level #1' do

#       before(:each) do
#         @sub_page_1.reload
#         @sub_page_2.reload
#       end

#       it 'exists' do
#         expect(@sub_page_1.editable_elements.size).to eq(1)
#         expect(@sub_page_2.editable_elements.size).to eq(1)
#       end

#       it 'has a non-nil slug' do
#         expect(@sub_page_1.editable_elements.first.slug).to eq('body')
#       end

#       it 'does not have a content at first' do
#         expect(@sub_page_1_el.default_content).to eq(true)
#         expect(@sub_page_1_el.content).to eq('Lorem ipsum')
#       end

#     end

#     describe 'in sub pages level #2' do

#       before(:each) do
#         @sub_page_1_1.reload
#       end

#       it 'exists' do
#         expect(@sub_page_1_1.editable_elements.size).to eq(1)
#       end

#       it 'has a non-nil slug' do
#         expect(@sub_page_1_1.editable_elements.first.slug).to eq('body')
#       end

#       it 'removes editable elements' do
#         @sub_page_1_1.editable_elements.destroy_all
#         @sub_page_1_1.reload
#         expect(@sub_page_1_1.editable_elements.size).to eq(0)
#       end

#     end

#   end

#   describe '"sticky" elements' do

#     before(:each) do
#       @site = FactoryGirl.create(:site)
#       @home = @site.pages.root.first

#       @home.update_attributes raw_template: "{% block body %}{% editable_text 'body', fixed: true %}Lorem ipsum{% endeditable_text %}{% endblock %}"
#       @home_el = @home.editable_elements.first

#       @sub_page_1 = FactoryGirl.create(:page, slug: 'sub_page_1', parent: @home, raw_template: "{% extends 'parent' %}")
#       @sub_page_2 = FactoryGirl.create(:page, slug: 'sub_page_2', parent: @home, raw_template: "{% extends 'parent' %}")

#       @sub_page_1_el = @sub_page_1.editable_elements.first
#       @sub_page_2_el = @sub_page_2.editable_elements.first
#     end

#     it 'exists in sub pages' do
#       expect(@sub_page_1.editable_elements.size).to eq(1)
#       expect(@sub_page_2.editable_elements.size).to eq(1)
#     end

#     it 'is marked as fixed' do
#       expect(@sub_page_1_el.fixed?).to eq(true)
#       expect(@sub_page_2_el.fixed?).to eq(true)
#     end

#     it 'enables the default content when it just got created' do
#       expect(@sub_page_1_el.default_content?).to eq(true)
#     end

#     it 'disables the default content if the content changed' do
#       @sub_page_1_el.content = 'Bla bla'
#       expect(@sub_page_1_el.default_content?).to eq(false)
#     end

#     it 'gets also updated when updating the very first element' do
#       @home_el.content = 'Hello world'
#       @home.save
#       @sub_page_1.reload; @sub_page_1_el = @sub_page_1.editable_elements.first
#       @sub_page_2.reload; @sub_page_2_el = @sub_page_2.editable_elements.first
#       expect(@sub_page_1_el.content).to eq('Hello world')
#       expect(@sub_page_2_el.content).to eq('Hello world')
#     end

#   end

# end
