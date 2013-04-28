require 'spec_helper'

describe Locomotive::GlobalActionsCell do

  let(:menu) { render_cell('locomotive/global_actions', :show, current_locomotive_account: FactoryGirl.build('admin user'), current_site_url: 'http://www.yahoo.fr') }

  describe 'show menu' do

    before(:all) do
      reset_cell(main: 'settings', sub: 'site')
    end

    it 'has 3 links' do
      menu.should have_selector('a', count: 4)
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

    before(:all) do
      reset_cell(main: 'settings', sub: 'site')
      Locomotive::GlobalActionsCell.update_for(:testing_add) { |m| m.add(:my_link, label: 'My link', url: 'http://www.locomotivecms.com') }
    end

    it 'has 4 items' do
      menu.should have_selector('a', count: 5)
    end

    it 'has a new link' do
      menu.should have_link('My link')
    end

  end

  describe 'remove a new menu item' do

    before(:all) do
      reset_cell(main: 'settings', sub: 'site')
      Locomotive::GlobalActionsCell.update_for(:testing_remove) { |m| m.remove(:see) }
    end

    it 'has 2 items' do
      menu.should have_selector('a', count: 3)
    end

    it 'does not have the link to see my website' do
      menu.should_not have_link('See website')
    end

  end

  describe 'modify an existing menu item' do

    before(:all) do
      reset_cell(main: 'settings', sub: 'site')
      Locomotive::GlobalActionsCell.update_for(:testing_update) { |m| m.modify(:see, { label: 'Modified !' }) }
    end

    it 'still has 3 items' do
      menu.should have_selector('a', count: 4)
    end

    it 'has a modified menu item' do
      menu.should_not have_link('See website')
      menu.should have_link('Modified !')
    end

  end

  after(:all) do
    reset_cell
  end

  def reset_cell(attributes = {})
    ::Locomotive.send(:remove_const, 'GlobalActionsCell')

    cell_path = File.join(File.dirname(__FILE__), '../../../app/cells/locomotive/global_actions_cell.rb')
    load cell_path

    unless attributes.empty?
      Locomotive::GlobalActionsCell.any_instance.stubs(:sections).returns(attributes)
    end
  end

end
