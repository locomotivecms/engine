require 'spec_helper'

module Resetter

  @@original_settings_menu_cell_klass = Admin::SettingsMenuCell

  def self.original_settings_menu_cell_klass
    @@original_settings_menu_cell_klass
  end

  def self.reset_settings_menu_cell_klass
    ::Admin.send(:remove_const, 'SettingsMenuCell')
    ::Admin.const_set('SettingsMenuCell', self.original_settings_menu_cell_klass.clone)
    ::Admin::SettingsMenuCell.any_instance.stubs(:sections).returns({ :main => 'settings', :sub => 'site' })
  end

end

# puts "initial object_id = #{@original_settings_menu_cell_klass.object_id}"

# def reset_settings_menu_cell!
#   ::Admin.send(:remove_const, 'SettingsMenuCell') rescue nil
#   load 'admin/settings_menu_cell.rb'
#   # ::Admin.const_set('SettingsMenuCell', @original_settings_menu_cell_klass)
# end

describe Admin::SettingsMenuCell, :type => :cells do

  render_views

  # before(:each) do
  #   puts "1...#{Admin::SettingsMenuCell.object_id}"
  #   # @original_settings_menu_cell_klass = Admin::SettingsMenuCell.clone
  #   # ::Admin.send(:remove_const, 'SettingsMenuCell')
  #   # ::Admin.const_set('SettingsMenuCell', @original_settings_menu_cell_klass.clone)
  #   # @cell_klass = Class.new(Admin::SettingsMenuCell)
  #   # reset_settings_menu_cell!
  #
  #   # Resetter.reset_settings_menu_cell_klass
  #
  #   # Admin::SettingsMenuCell.any_instance.stubs(:sections).returns({ :main => 'settings', :sub => 'site' })
  # end
  #
  # after(:each) do
  #   puts "2....#{Admin::SettingsMenuCell.object_id} (polluted) / clone: #{Resetter.original_settings_menu_cell_klass.object_id} (cleaned)"
  #   # ::Admin.send(:remove_const, 'SettingsMenuCell')
  #   # ::Admin.const_set('SettingsMenuCell', @original_settings_menu_cell_klass)
  # end

  let(:menu) { render_cell('admin/settings_menu', :show) }

  describe 'show menu' do

    before(:all) do
      Resetter.reset_settings_menu_cell_klass
    end

    it 'has 3 items' do
      puts "1...#{Admin::SettingsMenuCell.object_id}"
      menu.should have_selector('li', :count => 3)
    end

    it 'has a link to edit the current site' do
      puts "2...#{Admin::SettingsMenuCell.object_id}"
      menu.should have_link('Site')
    end

    it 'has a link to edit the template files' do
      puts "3...#{Admin::SettingsMenuCell.object_id}"
      menu.should have_link('Theme files')
    end

    it 'has a link to edit my account' do
      puts "4...#{Admin::SettingsMenuCell.object_id}"
      menu.should have_link('My account')
    end

  end

  describe 'add a new menu item' do

    before(:each) do
      Resetter.reset_settings_menu_cell_klass
      Admin::SettingsMenuCell.update_for(:add) { |m| m.add(:my_link, :label => 'My link', :url => 'http://www.locomotivecms.com') }
    end

    it 'has 4 items' do
      menu.should have_selector('li', :count => 4)
    end

    it 'has a new link' do
      menu.should have_link('My link')
    end

  end

  describe 'remove a new menu item' do

    before(:each) do
      Resetter.reset_settings_menu_cell_klass
      Admin::SettingsMenuCell.update_for(:remove) { |m| m.remove(:theme_assets) }
    end

    it 'has 2 items' do
      menu.should have_selector('li', :count => 2)
    end

    it 'does not have the link to edit the template files' do
      menu.should_not have_link('Theme files')
    end

  end

  # describe 'add / remove / edit menu items' do
  #
  #
  #
  #
  # end

  # describe "search posts" do
  #   let(:search) { render_cell(:posts, :search) }
  #
  #   it "should have a search field" do
  #     search.should have_field("Search by Title")
  #   end
  #
  #   it "should have a search button" do
  #     search.should have_button("Search")
  #   end
  # end
  #
  # describe "latest posts" do
  #   subject { render_cell(:posts, :latest) }
  #
  #   it { should have_css("h3.title", :text => "Latest Posts") }
  #   it { should have_table("latest_posts") }
  #   it { should have_link("View all Posts") }
  #   it { should_not have_button("Create Post") }
  #   it { should_not have_field("Search by Title") }
  # end

end