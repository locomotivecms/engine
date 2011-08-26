require 'spec_helper'

describe Admin::GlobalActionsCell do

  render_views

  let(:menu) { render_cell('admin/global_actions', :show, :current_admin => FactoryGirl.build('admin user'), :current_site_url => 'http://www.yahoo.fr') }

  describe 'show menu' do

    before(:each) do
      CellsResetter.new_global_actions_cell_klass({ :main => 'settings', :sub => 'site' })
    end

    it 'has 3 links' do
      menu.should have_selector('a', :count => 4)
    end

    it 'has a link to edit my account' do
      menu.should have_link('Admin')
    end

    it 'has a link to see my website' do
      menu.should have_link('See website')
    end

    it 'has a link to log out' do
      menu.should have_link('Log out')
    end

  end

  describe 'add a new menu item' do

    before(:each) do
      CellsResetter.new_global_actions_cell_klass({ :main => 'settings', :sub => 'site' })
      Admin::GlobalActionsCell.update_for(:testing_add) { |m| m.add(:my_link, :label => 'My link', :url => 'http://www.locomotivecms.com') }
    end

    it 'has 4 items' do
      menu.should have_selector('a', :count => 5)
    end

    it 'has a new link' do
      menu.should have_link('My link')
    end

  end

  describe 'remove a new menu item' do

    before(:each) do
      CellsResetter.new_global_actions_cell_klass({ :main => 'settings', :sub => 'site' })
      Admin::GlobalActionsCell.update_for(:testing_remove) { |m| m.remove(:see) }
    end

    it 'has 2 items' do
      menu.should have_selector('a', :count => 3)
    end

    it 'does not have the link to see my website' do
      menu.should_not have_link('See website')
    end

  end

  describe 'modify an existing menu item' do

    before(:each) do
      CellsResetter.new_global_actions_cell_klass({ :main => 'settings', :sub => 'site' })
      Admin::GlobalActionsCell.update_for(:testing_update) { |m| m.modify(:see, { :label => 'Modified !' }) }
    end

    it 'still has 3 items' do
      menu.should have_selector('a', :count => 4)
    end

    it 'has a modified menu item' do
      menu.should_not have_link('See website')
      menu.should have_link('Modified !')
    end

  end

  after(:all) do
   CellsResetter.clean!
  end

end