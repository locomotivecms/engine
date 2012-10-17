require 'spec_helper'

describe Locomotive::SettingsMenuCell do

  let(:menu) { render_cell('locomotive/settings_menu', :show) }

  describe 'show menu' do

    before(:all) do
      reset_cell(:main => 'settings', :sub => 'site')
    end

    it 'has 4 items' do
      menu.should have_selector('li', :count => 4)
    end

    it 'has a link to edit the current site' do
      menu.should have_link('Site')
    end

    it 'has a link to edit the template files' do
      menu.should have_link('Theme files')
    end
    
    it "has a link to edit the translations" do
      menu.should have_link('Translations')
    end

    it 'has a link to edit my account' do
      menu.should have_link('My account')
    end

  end

  describe 'add a new menu item' do

    before(:all) do
      reset_cell(:main => 'settings', :sub => 'site')
      Locomotive::SettingsMenuCell.update_for(:testing_add) { |m| m.add(:my_link, :label => 'My link', :url => 'http://www.locomotivecms.com') }
    end

    it 'has 5 items' do
      menu.should have_selector('li', :count => 5)
    end

    it 'has a new link' do
      menu.should have_link('My link')
    end

  end

  describe 'remove a new menu item' do

    before(:all) do
      reset_cell(:main => 'settings', :sub => 'site')
      Locomotive::SettingsMenuCell.update_for(:testing_remove) { |m| m.remove(:theme_assets) }
    end

    it 'has 3 items' do
      menu.should have_selector('li', :count => 3)
    end

    it 'does not have the link to edit the template files' do
      menu.should_not have_link('Theme files')
    end

  end

  describe 'modify an existing menu item' do

    before(:all) do
      reset_cell(:main => 'settings', :sub => 'site')
      Locomotive::SettingsMenuCell.update_for(:testing_update) { |m| m.modify(:theme_assets, { :label => 'Modified !' }) }
    end

    it 'still has 4 items' do
      menu.should have_selector('li', :count => 4)
    end

    it 'has a modified menu item' do
      menu.should_not have_link('Theme files')
      menu.should have_link('Modified !')
    end

  end

  after(:all) do
    reset_cell
  end

  def reset_cell(attributes = {})
    ::Locomotive.send(:remove_const, 'SettingsMenuCell')

    cell_path = File.join(File.dirname(__FILE__), '../../../app/cells/locomotive/settings_menu_cell.rb')
    load cell_path

    unless attributes.empty?
      # weird issue: Locomotive::GlobalActionsCell.any_instance does not work at all
      Locomotive::SettingsMenuCell.class_eval <<-EOV
        def sections(*args)
          #{attributes.inspect}
        end
      EOV
    end
  end

end
