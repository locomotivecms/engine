# coding: utf-8

require 'spec_helper'

describe Locomotive::PageService do

  let!(:site)     { create(:site) }
  let(:account)   { create(:account) }
  let(:service)   { described_class.new(site, account) }

  describe '#create' do

    subject { service.create(title: 'Hello world') }

    it { expect { subject }.to change { Locomotive::Page.count }.by 1 }

    it { expect(subject.title).to eq 'Hello world' }

  end

  describe '#update' do

    let(:page) { site.pages.root.first }

    subject { service.update(page, title: 'My new home page') }

    it { expect(subject.title).to eq 'My new home page' }

  end

end
