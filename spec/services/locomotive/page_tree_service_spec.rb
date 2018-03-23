# encoding: utf-8

describe Locomotive::PageTreeService do

  let(:site)    { create_site }
  let(:service) { described_class.new(site) }

  describe '.tree' do

    subject { service.build_tree.map(&:first) }

    it { expect(subject.map(&:title)).to eq ['Home page', 'Blog', 'Features', 'Page not found'] }

    describe 'depth = 1' do

      subject { service.build_tree[2].last.map(&:first).sort_by(&:position) }

      it { expect(subject.map(&:title)).to eq ['Awesome feature #1', 'Awesome feature #2'] }

    end

  end

  def create_site
    create(:site).tap do |site|
      index = site.pages.first

      # depth 1
      create(:page, title: 'Blog', slug: nil, site: site, parent: index)
      features = create(:page, title: 'Features', slug: nil, site: site, parent: index)

      # depth 2
      create(:page, title: 'Awesome feature #1', slug: nil, site: site, parent: features, position: 1)
      create(:page, title: 'Awesome feature #2', slug: nil, site: site, parent: features, position: 2)
    end

  end

end
