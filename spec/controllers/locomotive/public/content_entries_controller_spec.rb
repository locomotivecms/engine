require 'spec_helper'

describe Locomotive::Public::ContentEntriesController do

  let(:site) { FactoryGirl.create('existing site') }
  let(:content_type) { build_content_type }

  before do
    request.env['locomotive.site'] = site
    controller.stubs(:current_locomotive_account).returns(nil)
  end

  describe 'POST create' do

    let(:format) { 'html' }
    let(:entry_params) { {} }

    before { post :create, { format: format, slug: content_type.slug, entry: entry_params } }

    describe 'in HTML' do

      describe 'wrong entry' do

        it 'returns a 200 code' do
          response.status.should eq(200)
        end

      end

      describe 'valid entry' do

        let(:entry_params) { { email: 'john@doe.net', message: 'hello world' } }

        it 'returns a 200 code' do
          response.status.should eq(302)
          controller.flash['submitted_entry_id'].should_not eq(nil)
        end

      end

    end

    describe 'in JSON' do

      let(:format) { 'json' }

      describe 'wrong entry' do

        it 'returns a 422 error code' do
          response.status.should eq(422)
        end

      end

      describe 'valid entry' do

        let(:entry_params) { { email: 'john@doe.net', message: 'hello world' } }

        it 'returns a 201 code' do
          response.status.should eq(201)
        end

      end

    end

  end

  def build_content_type
    FactoryGirl.build(:content_type, site: site).tap do |content_type|
      content_type.entries_custom_fields.build label: 'Email', type: 'email', required: true
      content_type.entries_custom_fields.build label: 'Message', type: 'text'
      content_type.public_submission_enabled = true
      content_type.save
    end
  end

end