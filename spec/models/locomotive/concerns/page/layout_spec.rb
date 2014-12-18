require 'spec_helper'

describe Locomotive::Concerns::Page::Layout do

  let(:site)          { FactoryGirl.build(:site) }
  let(:allow_layout)  { true }
  let(:layout)        { Locomotive::Page.new(is_layout: true, fullpath: 'awesome-layout') }
  let(:page)          { Locomotive::Page.new(layout: layout, allow_layout: allow_layout, site: site) }

  describe 'allow_layout default value' do

    let(:page) { Locomotive::Page.new }

    subject { page.allow_layout }

    describe 'true for a new page' do

      it { is_expected.to eq true }

    end

    describe 'false for an existing page without the allow_layout attribute' do

      let(:page) { p = Locomotive::Page.new; p.save(validate: false); p.unset(:allow_layout); Locomotive::Page.find(p._id) }

      it { is_expected.to eq false }

    end

  end

  describe 'use a layout' do

    before { page.valid? }

    subject { page.raw_template }

    it { is_expected.to eq '{% extends "awesome-layout" %}' }

    describe 'but changing the layout is not allowed' do

      let(:allow_layout) { false }

      it { is_expected.to eq "{% extends 'parent' %}" }

    end

  end

end
