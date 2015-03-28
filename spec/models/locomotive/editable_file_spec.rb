# require 'spec_helper'

# describe Locomotive::EditableFile do

#   before(:each) do
#     @site = FactoryGirl.create(:site)
#     @home = @site.pages.root.first

#     @home.update_attributes raw_template: "{% block body %}{% editable_file 'image' %}Lorem ipsum{% endeditable_file %}{% endblock %}"

#     @home = @site.pages.root.first
#   end

#   it 'has one editable file element' do
#     expect(@home.editable_elements.size).to eq(1)
#     expect(@home.editable_elements.first.slug).to eq('image')
#   end

#   it 'disables the default content flag if the remove_source method is called' do
#     @home.editable_elements.first.remove_source = true
#     @home.save; @home.reload
#     expect(@home.editable_elements.first.default_content?).to be(false)
#   end

#   it 'disables the default content when a new file is uploaded' do
#     @home.editable_elements.first.source = FixturedAsset.open('5k.png')
#     @home.save
#     expect(@home.editable_elements.first.default_content?).to be(false)
#   end

#   it 'does not have 2 image fields' do
#     editable_file = @home.editable_elements.first
#     fields = editable_file.class.fields.keys
#     expect(fields.include?('source') && fields.include?(:source)).to be(false)
#   end

#   describe 'with an attached file' do

#     before(:each) do
#       @editable_file = @home.editable_elements.first
#       @editable_file.source = FixturedAsset.open('5k.png')
#       @home.save
#       @home.reload
#     end

#     it 'has a valid source' do
#       expect(@editable_file.source?).to be(true)
#     end

#     it 'returns the right path even if the page has been retrieved with the minimum_attributes scope' do
#       @home = @site.pages.root.first
#       expect(@home.editable_elements.first.source?).to be(true)
#     end

#   end

#   describe '"sticky" files' do

#     before(:each) do
#       @home.update_attributes raw_template: "{% block body %}{% editable_file 'image', fixed: true %}/foo.png{% endeditable_file %}{% endblock %}"

#       @sub_page_1 = FactoryGirl.create(:page, slug: 'sub_page_1', parent: @home, raw_template: "{% extends 'index' %}")
#       @sub_page_2 = FactoryGirl.create(:page, slug: 'sub_page_2', parent: @home, raw_template: "{% extends 'index' %}")

#       @sub_page_1_el = @sub_page_1.editable_elements.first
#       @sub_page_2_el = @sub_page_2.editable_elements.first
#     end

#     it 'exists in sub pages' do
#       expect(@sub_page_1.editable_elements.size).to eq(1)
#       expect(@sub_page_2.editable_elements.size).to eq(1)
#     end

#     it 'is marked as fixed' do
#       expect(@sub_page_1_el.fixed?).to be(true)
#       expect(@sub_page_2_el.fixed?).to be(true)
#     end

#     it 'enables the default content when it just got created' do
#       expect(@sub_page_1_el.source?).to be(false)
#       expect(@sub_page_1_el.default_source_url).to eq('/foo.png')
#       expect(@sub_page_1_el.default_content?).to be(true)
#     end

#     it 'gets also updated when updating the very first element' do
#       @home.editable_elements.first.source = FixturedAsset.open('5k.png')
#       @home.save; @sub_page_1.reload; @sub_page_2.reload
#       expect(@sub_page_1.editable_elements.first.default_source_url).to match(/files\/5k.png$/)
#       expect(@sub_page_2.editable_elements.first.default_source_url).to match(/files\/5k.png$/)
#     end

#   end

# end
