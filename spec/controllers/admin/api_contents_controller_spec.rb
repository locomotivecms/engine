require 'spec_helper'

describe Admin::ApiContentsController do

  before(:each) do
    @site = FactoryGirl.create('existing site')
    @site.content_types.first.tap do |content_type|
      content_type.content_custom_fields.build :label => 'Name', :kind => 'string', :required => true
      content_type.content_custom_fields.build :label => 'Description', :kind => 'text'
      content_type.content_custom_fields.build :label => 'File', :kind => 'file'
      content_type.content_custom_fields.build :label => 'Active', :kind => 'boolean'
    end.save

    controller.stubs(:require_site).returns(true)
    controller.stubs(:current_site).returns(@site)
  end

  describe 'API disabled' do

    it 'blocks the creation of a new instance' do
      post 'create', default_post_params

      response.code.should eq('403')
      response.body.should == 'Api not enabled'
    end

  end

  describe 'API enabled' do

    before(:each) do
      ContentType.any_instance.stubs(:api_enabled?).returns(true)
    end

    it 'saves a content' do
      post 'create', default_post_params

      response.should redirect_to('http://www.locomotivecms.com/success')

      @site.reload.content_types.first.contents.size.should == 1
    end

    it 'does not save a content if required parameters are missing' do
      post 'create', default_post_params(:content => { :name => '' })

      response.should redirect_to('http://www.locomotivecms.com/failure')

      @site.reload.content_types.first.contents.size.should == 0
    end

    describe 'XSS vulnerability' do

      it 'sanitizes the params (simple example)' do
        post 'create', default_post_params(:content => { :name => %(Hacking <script type="text/javascript">alert("You have been hacked")</script>) })

        content = @site.reload.content_types.first.contents.first

        content.name.should == "Hacking alert(\"You have been hacked\")"
      end

      it 'sanitizes the params (more complex example)' do
        post 'create', default_post_params(:content => { :name => %(<img src=javascript:alert('Hello')><table background="javascript:alert('Hello')">Hacked) })

        content = @site.reload.content_types.first.contents.first

        content.name.should == "Hacked"
      end

      it 'does not sanitize non string params' do
        lambda {
          post 'create', default_post_params(:content => {
            :active => true,
            :file => ActionDispatch::Http::UploadedFile.new(:tempfile => FixturedAsset.open('5k.png'), :filename => '5k.png', :content_type => 'image/png')
          })
        }.should_not raise_exception
      end

    end

  end

  def default_post_params(options = {})
    {
      :slug => 'projects',
      :content => { :name => 'LocomotiveCMS', :description => 'Lorem ipsum' }.merge(options.delete(:content) || {}),
      :success_callback => 'http://www.locomotivecms.com/success',
      :error_callback => 'http://www.locomotivecms.com/failure'
    }.merge(options)
  end

end