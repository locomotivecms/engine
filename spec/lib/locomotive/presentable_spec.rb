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
    expect(@presenter.name).to eq('John')
  end

  it 'has properties from the parent' do
    expect(@presenter.id).to eq(42)
  end

  it 'does not have properties from another sibling class' do
    expect(@presenter.respond_to?(:title)).to eq(false)
    expect(@other_presenter.respond_to?(:name)).to eq(false)
    expect(@other_presenter.respond_to?(:id)).to eq(true)
  end

  it 'uses the overridden getter' do
    expect(@presenter.age).to eq('23 years old')
  end

  it 'can set a value and retrieve it' do
    @presenter.age = 33
    expect(@presenter.age).to eq('33 years old')
  end

  it 'does not add a getter if specified' do
    expect { @presenter.address }.to raise_exception
  end

  it 'responds to aliases' do
    @presenter.full_address = '700 S Laflin, Chicago'
    expect(@person.address).to eq('700 S Laflin, Chicago')
  end

  it 'returns the attributes' do
    expect(@presenter.as_json).to eq({ 'id' => 42, 'name' => 'John', 'age' => '23 years old', 'projects' => [] })
  end

  it 'sets directly the attributes' do
    @presenter.attributes = { name: 'henry', age: 33 }
    expect(@presenter.name).to eq('Henry')
    expect(@presenter.age).to eq('33 years old')
  end

  it 'does not call the setter if not registered' do
    @presenter.expects(:unknown=).never
    @presenter.attributes = { name: 'henry', unknown: true }
  end

  it 'handles with_options' do
    expect(@presenter.respond_to?(:notes)).to eq(true)
    expect(@presenter.respond_to?(:notes=)).to eq(false)
  end

  it 'stores the list of getters' do
    expect(@presenter.getters).to eq(%w(id name age projects notes retirement_place))
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
        expect(@presenter.as_json.keys).to_not include('retirement_place')
      end

      it 'does not allow to change the property' do
        @presenter.attributes = { retirement_place: 'Mansion [UPDATE]' }
        expect(@person.retirement_place).to eq('Mansion')
      end

    end

    context 'true' do

      before(:each) do
        @person.age = 61
      end

      it 'returns the property if the block returns true' do
        expect(@presenter.as_json.keys).to include('retirement_place')
      end

      it 'changes the property' do
        @presenter.attributes = { retirement_place: 'Mansion [UPDATE]' }
        expect(@person.retirement_place).to eq('Mansion [UPDATE]')
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
      expect(@presenter).to respond_to(:projects)
    end

    it 'returns a hash as the collection' do
      @project.expects(:as_json).returns({ 'id' => 1 }).once
      @another_project.expects(:as_json).returns({ 'id' => 2 }).once
      expect(@presenter.projects).to eq([{ 'id' => 1 }, { 'id' => 2 }])
    end

  end

  ## classes for tests ##

  class FakeBasePresenter

    include Locomotive::Presentable

    property :id

  end

  class PersonPresenter < FakeBasePresenter

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

  class ProjectPresenter < FakeBasePresenter

    property  :title

  end

end
