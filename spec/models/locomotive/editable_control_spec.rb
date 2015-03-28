# require 'spec_helper'

# describe Locomotive::EditableControl do

#   before(:each) do
#     @site = FactoryGirl.create(:site)
#     @home = @site.pages.root.first
#   end

#   describe '#simple' do

#     before(:each) do
#       @home.update_attributes raw_template: %({% block body %}{% editable_control 'menu', options: "true=Yes,false=No" %}false{% endeditable_control %}{% endblock %}%)

#       @sub_page_1 = FactoryGirl.create(:page, slug: 'sub_page_1', parent: @home, raw_template: "{% extends 'parent' %}")
#     end

#     it 'exists' do
#       expect(@sub_page_1.editable_elements.size).to eq(1)
#     end

#     it 'has a non-nil slug' do
#       expect(@sub_page_1.editable_elements.first.slug).to eq('menu')
#     end

#     it 'has a default value' do
#       expect(@sub_page_1.editable_elements.first.content).to eq('false')
#     end

#     it 'has a list of options' do
#       expect(@sub_page_1.editable_elements.first.options).to eq([{ 'value' => 'true', 'text' => 'Yes' }, { 'value' => 'false', 'text' => 'No' }])
#     end

#     it 'removes leading and trailling characters' do
#       @home.update_attributes raw_template: %({% block body %}
#       {% editable_control 'menu', options: 'true=Yes,false=No' %}
#         true
#       {% endeditable_control %}
#       {% endblock %})
#       expect(@home.editable_elements.first.content).to eq('true')
#     end

#   end

#   describe '"sticky" elements' do

#     before(:each) do
#       @home.update_attributes raw_template: "{% block body %}{% editable_control 'menu', options: 'true=Yes,false=No', fixed: true %}false{% endeditable_control %}{% endblock %}"
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

#     it 'gets also updated when updating the very first element' do
#       @home_el.content = 'true'
#       @home.save
#       @sub_page_1.reload; @sub_page_1_el = @sub_page_1.editable_elements.first
#       @sub_page_2.reload; @sub_page_2_el = @sub_page_2.editable_elements.first
#       expect(@sub_page_1_el.content).to eq('true')
#       expect(@sub_page_2_el.content).to eq('true')
#     end

#   end

# end
