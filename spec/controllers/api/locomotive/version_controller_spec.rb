require 'spec_helper'

describe Locomotive::Api::VersionController do

  describe 'GET #show' do

    subject { get :show, format: :json }

    it { is_expected.to be_success }
    it 'returns a the version' do
      expect(json_response['engine']).to eq Locomotive::VERSION
    end

  end

  def json_response
    JSON.parse(subject.body)
  end

end
