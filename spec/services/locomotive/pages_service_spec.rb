# coding: utf-8

require 'spec_helper'

describe Locomotive::PagesService do
  let(:site)    { create_site }
  let(:service) { Locomotive::PagesService.new(site) }

  describe '.tree' do
    subject { service.build_tree.map(&:first) }

    it { subject.map(&:title).should eq ['Home page', 'Blog', 'Features', 'Page not found'] }

    describe 'depth = 1' do
      subject { service.build_tree[2].last.map(&:first) }
      it { subject.map(&:title).should eq ['Awesome feature #1', 'Awesome feature #2'] }
    end
  end

  def create_site
    FactoryGirl.create(:site).tap do |site|
      index = site.pages.first

      # depth 1
      FactoryGirl.create(:page, title: 'Blog', slug: nil, site: site, parent: index)
      features = FactoryGirl.create(:page, title: 'Features', slug: nil, site: site, parent: index)

      # depth 2
      FactoryGirl.create(:page, title: 'Awesome feature #1', slug: nil, site: site, parent: features)
      FactoryGirl.create(:page, title: 'Awesome feature #2', slug: nil, site: site, parent: features)
    end
  end
end
