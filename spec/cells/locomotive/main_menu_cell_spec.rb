require 'spec_helper'

describe Locomotive::MainMenuCell do

  let(:menu) { render_cell('locomotive/main_menu', :show) }

  describe 'show menu' do

    before(:all) { reset_cell }

    it 'has 3 items' do
      menu.should have_selector('li.entry', count: 3)
    end

    it 'has a link to go to the contents' do
      menu.should have_link('Contents')
    end

    it 'has a link to go the settings' do
      menu.should have_link('Settings')
    end

    it 'has a link to go the foo tab' do
      menu.should have_link('My FOO menu')
    end

  end

  describe 'add a new menu item' do

    before(:all) do
      reset_cell(main: 'settings', sub: 'site')
      Locomotive::MainMenuCell.update_for(:testing_add) { |m| m.add(:my_link, label: 'Shop', url: 'http://www.locomotivecms.com') }
    end

    it 'has 4 items now' do
      menu.should have_selector('li.entry', count: 4)
    end

    it 'has a new link' do
      menu.should have_link('Shop')
    end

  end

  describe 'remove a new menu item' do

    before(:all) do
      reset_cell(main: 'settings', sub: 'site')
      Locomotive::MainMenuCell.update_for(:testing_remove) { |m| m.remove(:settings) }
    end

    it 'has only 2 items' do
      menu.should have_selector('li.entry', count: 2)
    end

    it 'does not have the link to go to the settings' do
      menu.should_not have_link('Settings')
    end

  end

  describe 'modify an existing menu item' do

    before(:all) do
      reset_cell(main: 'settings', sub: 'site')
      Locomotive::MainMenuCell.update_for(:testing_update) { |m| m.modify(:settings, { label: 'Modified !' }) }
    end

    it 'still has 3 items' do
      menu.should have_selector('li.entry', count: 3)
    end

    it 'has a modified menu item' do
      menu.should_not have_link('Settings')
      menu.should have_link('Modified !')
    end

  end

  after(:all) do
    reset_cell
  end

  def reset_cell(attributes = {})
    ::Locomotive.send(:remove_const, 'MainMenuCell')

    cell_path = File.join(File.dirname(__FILE__), '../../../app/cells/locomotive/main_menu_cell.rb')
    load cell_path

    cell_path = File.join(File.dirname(__FILE__), '../../dummy/app/cells/locomotive/main_menu_cell.rb')
    load cell_path

    unless attributes.empty?
      Locomotive::MainMenuCell.any_instance.stubs(:sections).returns(attributes)
    end
  end

end
