require 'spec_helper'

describe Locomotive::Api::VersionController do

  describe 'GET #show' do

    subject { get :show, format: :json }

    it { should be_success }
    it 'returns a the version' do
      json_response['engine'].should eq Locomotive::VERSION
    end

  end

  def json_response
    JSON.parse(subject.body)
  end

end
