require 'spec_helper'

describe Locomotive::EditableElement do

  before(:each) do
    @site = FactoryGirl.create(:site)
    @home = @site.pages.root.first

    @home.update_attributes :raw_template => "{% block body %}{% editable_file 'image' %}Lorem ipsum{% endeditable_file %}{% endblock %}"

    @home = @site.pages.root.first
  end

  it 'has one editable file element' do
    @home.editable_elements.size.should == 1
    @home.editable_elements.first.slug.should == 'image'
  end

  it 'does not have 2 image fields' do
    editable_file = @home.editable_elements.first
    fields = editable_file.class.fields.keys
    (fields.include?('source') && fields.include?(:source)).should be_false
  end

end
