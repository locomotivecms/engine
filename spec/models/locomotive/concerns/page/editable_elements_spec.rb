# require 'spec_helper'

# describe Locomotive::Concerns::Page::EditableElements do

#   before(:each) do
#     @site = FactoryGirl.create(:site)
#     @home = @site.pages.root.first

#     @home.update_attributes raw_template: "{% editable_text 'body' %}Lorem ipsum{% endeditable_text %}"

#     @sub_page_1 = FactoryGirl.create(:page, slug: 'sub_page_1', parent: @home, raw_template: "{% extends 'parent' %}")
#     @sub_page_2 = FactoryGirl.create(:page, slug: 'sub_page_2', parent: @home, raw_template: "{% extends 'parent' %}")

#     @sub_page_1_el = @sub_page_1.editable_elements.first

#     @sub_page_1_1 = FactoryGirl.create(:page, slug: 'sub_page_1_1', parent: @sub_page_1, raw_template: "{% extends 'parent' %}")
#   end

#   describe 'modification of an element within the home page' do

#     before(:each) do
#       @home = Locomotive::Page.find(@home._id)
#     end

#     it 'keeps the same number of editable elements in all the children' do
#       @home.update_attributes raw_template: "{% editable_file 'body' %}/nowhere.pdf{% endeditable_file %}"
#       expect(@sub_page_1.reload.editable_elements.size).to eq(1)
#       expect(@sub_page_1_1.reload.editable_elements.size).to eq(1)
#     end

#     it 'changes the type of the element in all the children' do
#       @home.update_attributes raw_template: "{% editable_file 'body' %}/nowhere.pdf{% endeditable_file %}"
#       @sub_page_1.reload
#       expect(@sub_page_1.editable_elements.first._type).to eq('Locomotive::EditableFile')
#       @sub_page_1_1.reload
#       expect(@sub_page_1_1.editable_elements.first._type).to eq('Locomotive::EditableFile')
#     end

#     it 'changes the hint of the element in all the children' do
#       @home.update_attributes raw_template: "{% editable_text 'body', hint: 'My very useful hint' %}Lorem ipsum{% endeditable_text %}"
#       @sub_page_1.reload
#       expect(@sub_page_1.editable_elements.first.hint).to eq('My very useful hint')
#       @sub_page_1_1.reload
#       expect(@sub_page_1_1.editable_elements.first.hint).to eq('My very useful hint')
#     end

#   end

#   describe '#localized' do

#     it 'does not remove the editable elements in other locales' do
#       Mongoid::Fields::I18n.with_locale(:fr) do
#         @home.update_attributes raw_template: "{% editable_text 'corps' %}Lorem ipsum{% endeditable_text %}"
#       end
#       @home.reload
#       expect(@home.editable_elements.count).to eq(2)
#     end

#     it 'removes the editable elements which are not present in at least one locale' do
#       Mongoid::Fields::I18n.with_locale(:fr) do
#         @home.update_attributes raw_template: ''
#       end
#       @home.reload
#       expect(@home.editable_elements.count).to eq(1)

#       @home.update_attributes raw_template: ''
#       @home.reload
#       expect(@home.editable_elements.count).to eq(0)
#     end

#   end

# end
