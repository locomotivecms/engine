# coding: utf-8

require 'spec_helper'

describe Locomotive::SiteService do

  let(:account) { create(:account) }
  let(:service) { described_class.new(account) }

  describe '#list' do

    subject { service.list }

    it { is_expected.to eq [] }
  end

  describe '#build_new' do

    subject { service.build_new }

    it { expect(subject.handle).not_to eq nil }

  end

  describe '#create' do

    let(:attributes) { { name: 'Acme' } }
    subject { service.create(attributes) }

    it { expect { subject }.to change { Locomotive::Site.count }.by(1) }
    it { expect(subject.handle).not_to eq nil }

  end


end
