require 'spec_helper'

describe Locomotive::MainMenuCell do
  # FIXME: This does not seem to work correctly, rspec-cells should allow this to be called
  # as if it were a controller.
  # render_views

  let(:menu) { render_cell('locomotive/main_menu', :show) }

  describe 'show menu' do

    before(:each) do
      CellsResetter.new_main_menu_cell_klass({ :main => 'settings', :sub => 'site' })
    end

    it 'has 2 items' do
      menu.should have_selector('li.entry', :count => 2)
    end

    it 'has a link to go to the contents' do
      menu.should have_link('Contents')
    end

    it 'has a link to go the settings' do
      menu.should have_link('Settings')
    end

  end

  describe 'add a new menu item' do

    before(:each) do
      CellsResetter.new_main_menu_cell_klass({ :main => 'settings', :sub => 'site' })
      Locomotive::MainMenuCell.update_for(:testing_add) { |m| m.add(:my_link, :label => 'Shop', :url => 'http://www.locomotivecms.com') }
    end

    it 'has 3 items' do
      menu.should have_selector('li.entry', :count => 3)
    end

    it 'has a new link' do
      menu.should have_link('Shop')
    end

  end

  describe 'remove a new menu item' do

    before(:each) do
      CellsResetter.new_main_menu_cell_klass({ :main => 'settings', :sub => 'site' })
      Locomotive::MainMenuCell.update_for(:testing_remove) { |m| m.remove(:settings) }
    end

    it 'has only 1 item' do
      menu.should have_selector('li.entry', :count => 1)
    end

    it 'does not have the link to go to the settings' do
      menu.should_not have_link('Settings')
    end

  end

  describe 'modify an existing menu item' do

    before(:each) do
      CellsResetter.new_main_menu_cell_klass({ :main => 'settings', :sub => 'site' })
      Locomotive::MainMenuCell.update_for(:testing_update) { |m| m.modify(:settings, { :label => 'Modified !' }) }
    end

    it 'still has 2 items' do
      menu.should have_selector('li.entry', :count => 2)
    end

    it 'has a modified menu item' do
      menu.should_not have_link('Settings')
      menu.should have_link('Modified !')
    end

  end

  after(:all) do
    CellsResetter.clean!
  end

end
