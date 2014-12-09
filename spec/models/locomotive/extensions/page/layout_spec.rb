require 'spec_helper'

describe Locomotive::Extensions::Page::Layout do

  let(:site)          { FactoryGirl.build(:site) }
  let(:allow_layout)  { true }
  let(:layout)        { Locomotive::Page.new(is_layout: true, fullpath: 'awesome-layout') }
  let(:page)          { Locomotive::Page.new(layout: layout, allow_layout: allow_layout, site: site) }

  describe 'allow_layout default value' do

    let(:page) { Locomotive::Page.new }

    subject { page.allow_layout }

    describe 'true for a new page' do

      it { should eq true }

    end

    describe 'false for an existing page without the allow_layout attribute' do

      let(:page) { p = Locomotive::Page.new; p.save(validate: false); p.unset(:allow_layout); Locomotive::Page.find(p._id) }

      it { should eq false }

    end

  end

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
