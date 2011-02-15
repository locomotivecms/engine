require 'spec_helper'

describe Models::Extensions::Page::EditableElements do

	describe '#merge_editable_elements_from_page' do

		before :each do
			@site              = Factory.build(:site)
			@parent_page       = Factory.build(:page, :site => @site)
			@child_page        = Factory.build(:page, :site => @site)
			@active_ee         = Factory.build(:editable_element, :page => @parent_page, :slug => 'one')
			@disabled_ee       = Factory.build(:editable_element, :page => @parent_page, :disabled => true, :slug => 'two')
			@non_inherited_ee  = Factory.build(:editable_element, :page => @parent_page, :inheritable => false, :slug => 'three')
			@editable_elements = [ @active_ee, @disabled_ee, @non_inherited_ee ]

			@parent_page.stubs(:editable_elements).returns(@editable_elements)
			@active_ee.stubs(:content).returns('test content')
		end

		it 'copies all active and inheritable editable elements from the parent' do
			@child_page.merge_editable_elements_from_page(@parent_page)
			@child_page.editable_elements.size.should == 1
		end

		it 'assigns disabled to false on all editable elements' do
			@child_page.merge_editable_elements_from_page(@parent_page)
			@child_page.editable_elements.any? { |ee| ee.disabled? }.should be_false
		end

		it 'assigns the default content to the content of the merged in editable elements' do
			@child_page.merge_editable_elements_from_page(@parent_page)
			@child_page.editable_elements.first.default_content.should == 'test content'
		end

	end

end
