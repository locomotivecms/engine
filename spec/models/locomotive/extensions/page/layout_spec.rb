require 'spec_helper'

describe Locomotive::Extensions::Page::Layout do

  let(:site)          { FactoryGirl.build(:site) }
  let(:allow_layout)  { true }
  let(:layout)        { Locomotive::Page.new(is_layout: true, fullpath: 'awesome-layout') }
  let(:page)          { Locomotive::Page.new(layout: layout, allow_layout: allow_layout, site: site) }

  describe 'use a layout' do

    before { page.valid? }

    subject { page.raw_template }

    it { should eq '{% extends "awesome-layout" %}' }

    describe 'but changing the layout is not allowed' do

      let(:allow_layout) { false }

      it { should eq "{% extends 'parent' %}" }

    end

  end

end
