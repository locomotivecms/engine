require 'spec_helper'

describe Locomotive::Liquid::Drops::ContentTypes do
  
  before(:each) do
    @mock_content_type = FactoryGirl.build(:content_type)

    @contents_drop = Locomotive::Liquid::Drops::ContentTypes.new
    @contents_drop.stubs(:content_type_for_slug).returns(@mock_content_type)
  end

  context "accessing content_entries of a content type" do
    it "loops through the list" do
      template = %({% for project in contents.projects%}{{project}},{% endfor %})

      @mock_content_type.expects(:ordered_entries).returns(%w(a b))

      render(template, {'contents' => @contents_drop}).should == "a,b,"
    end

    it "filters the list" do
      template = %({%with_scope active: true%}{% for project in contents.projects%}{{project}},{% endfor %}{% endwith_scope %})

      @mock_content_type.expects(:ordered_entries).with("active" => true).returns(%w(a b))

      render(template, {'contents' => @contents_drop}).should == "a,b,"
    end



    context "filtering on select field type" do
      before(:each) do
        select_field = @mock_content_type.entries_custom_fields.build label: "Visibility", type: "select"
        @option_public = select_field.select_options.build name: "Public"
        @option_private = select_field.select_options.build name: "Private"
        @mock_content_type.save!
      end

      it "filters the list based on the select field name" do
        template = %({% with_scope visibility: 'Public' %}{% for project in contents.projects %}{{ project }},{% endfor %}{% endwith_scope %})

        @mock_content_type.expects(:ordered_entries).with({ 'visibility_id' => @option_public._id}, nil).returns(%w(a b))

        render(template, { 'contents' => @contents_drop }).should == 'a,b,'
      end

    end

  end


  def render(template, assigns ={})
    liquid_context = ::Liquid::Context.new(assigns, {}, {})

    output = ::Liquid::Template.parse(template).render(liquid_context)
    output.gsub(/\n\s{0,}/, '')
  end

end
