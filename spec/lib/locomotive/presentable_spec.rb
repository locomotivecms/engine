require 'spec_helper'
require 'ostruct'

describe Locomotive::Presentable do

  before(:each) do
    @person           = OpenStruct.new(id: 42, name: 'John', age: 23)
    @project          = OpenStruct.new(id: 1, title: 'LocomotiveCMS')

    @presenter        = PersonPresenter.new(@person)
    @other_presenter  = ProjectPresenter.new(@project)
  end

  it 'delegates a property to the source' do
    @presenter.name.should == 'John'
  end

  it 'has properties from the parent' do
    @presenter.id.should == 42
  end

  it 'does not have properties from another sibling class' do
    @presenter.respond_to?(:title).should be_false
    @other_presenter.respond_to?(:name).should be_false
    @other_presenter.respond_to?(:id).should be_true
  end

  it 'uses the overridden getter' do
    @presenter.age.should == '23 years old'
  end

  it 'can set a value and retrieve it' do
    @presenter.age = 33
    @presenter.age.should == '33 years old'
  end

  it 'does not add a getter if specified' do
    lambda { @presenter.address }.should raise_exception
  end

  it 'responds to aliases' do
    @presenter.full_address = '700 S Laflin, Chicago'
    @person.address.should == '700 S Laflin, Chicago'
  end

  it 'returns the attributes' do
    @presenter.as_json.should == { 'id' => 42, 'name' => 'John', 'age' => '23 years old', 'projects' => [] }
  end

  it 'sets directly the attributes' do
    @presenter.attributes = { name: 'henry', age: 33 }
    @presenter.name.should == 'Henry'
    @presenter.age.should == '33 years old'
  end

  it 'does not call the setter if not registered' do
    @presenter.expects(:unknown=).never
    @presenter.attributes = { name: 'henry', unknown: true }
  end

  it 'handles with_options' do
    @presenter.respond_to?(:notes).should be_true
    @presenter.respond_to?(:notes=).should be_false
  end

  it 'stores the list of getters' do
    @presenter.getters.should == %w(id name age projects notes retirement_place)
  end

  it 'executes custom code after setting attributes' do
    @presenter.expects(:hello_world).once
    @presenter.attributes = {}
  end

  describe '#if' do

    before(:each) do
      @person.retirement_place = 'Mansion'
    end

    context 'false' do

      it 'does not return the property' do
        @presenter.as_json.keys.should_not include('retirement_place')
      end

      it 'does not allow to change the property' do
        @presenter.attributes = { retirement_place: 'Mansion [UPDATE]' }
        @person.retirement_place.should == 'Mansion'
      end

    end

    context 'true' do

      before(:each) do
        @person.age = 61
      end

      it 'returns the property if the block returns true' do
        @presenter.as_json.keys.should include('retirement_place')
      end

      it 'changes the property' do
        @presenter.attributes = { retirement_place: 'Mansion [UPDATE]' }
        @person.retirement_place.should == 'Mansion [UPDATE]'
      end

    end

  end

  describe '#collection' do

    before(:each) do
      @another_project  = OpenStruct.new(id: 2, title: 'SocialTennis')
      @person.projects  = [@project, @another_project]

      @project.to_presenter = @other_presenter
      @another_project.to_presenter = ProjectPresenter.new(@another_project)
    end

    it 'has a getter for the collection' do
      @presenter.respond_to?(:projects)
    end

    it 'returns a hash as the collection' do
      @project.expects(:as_json).returns({ 'id' => 1 }).once
      @another_project.expects(:as_json).returns({ 'id' => 2 }).once
      @presenter.projects.should == [{ 'id' => 1 }, { 'id' => 2 }]
    end

  end

  ## classes for tests ##

  class BasePresenter

    include Locomotive::Presentable

    property :id

  end

  class PersonPresenter < BasePresenter

    properties  :name, :age
    property    :address, only_setter: true, alias: :full_address

    collection  :projects

    with_options only_getter: true, allow_nil: false do |presenter|
      presenter.property :notes
    end

    property :retirement_place, if: Proc.new { __source.age > 60 }

    set_callback :set_attributes, :after, :hello_world

    def name=(value)
      self.__source.name = value.capitalize
    end

    def unknown=(value)
      raise 'it should never happen'
    end

    def age
      "#{self.__source.age} years old"
    end

    def hello_world
      # do nothing
    end

  end

  class ProjectPresenter < BasePresenter

    property  :title

  end

end
