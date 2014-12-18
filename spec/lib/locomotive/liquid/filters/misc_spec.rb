require 'spec_helper'

describe Locomotive::Liquid::Filters::Misc do

  include Liquid::StandardFilters
  include Locomotive::Liquid::Filters::Base
  include Locomotive::Liquid::Filters::Misc

  it 'returns the input string every n occurences' do
    expect(str_modulo('foo', 0, 3)).to eq ''
    expect(str_modulo('foo', 1, 3)).to eq ''
    expect(str_modulo('foo', 2, 3)).to eq 'foo'
    expect(str_modulo('foo', 3, 3)).to eq ''
    expect(str_modulo('foo', 4, 3)).to eq ''
    expect(str_modulo('foo', 5, 3)).to eq 'foo'
  end

  it 'returns default values if the input is empty' do
    expect(default('foo', 42)).to eq 'foo'
    expect(default('', 42)).to eq 42
    expect(default(nil, 42)).to eq 42
  end

  describe 'split' do

    let(:string) { nil }
    subject { split(string, ',') }

    it { is_expected.to eq [] }

    context 'a not nil value' do

      let(:string) { 'foo,bar'}

      it { is_expected.to eq %w(foo bar) }

    end

  end

  describe 'random' do

    context 'from an integer' do

      subject { random(4) }
      it { is_expected.to be_a_kind_of(Fixnum) }
      it { is_expected.to satisfy { |n| n >=0 && n < 4 } }

    end

    context 'from a string' do

      subject { random('4') }
      it { is_expected.to be_a_kind_of(Fixnum) }
      it { is_expected.to satisfy { |n| n >=0 && n < 4 } }

    end

  end

  it 'returns a random number' do
    random_number = random(4)
    expect(random_number.class).to eq Fixnum
  end

  it 'returns a navigation block for the pagination' do
    pagination = {
      "previous"   => nil,
      "parts"     => [
        { 'title' => '1', 'is_link' => false },
        { 'title' => '2', 'is_link' => true, 'url' => '/?page=2' },
        { 'title' => '&hellip;', 'is_link' => false, 'hellip_break' => true },
        { 'title' => '5', 'is_link' => true, 'url' => '/?page=5' }
      ],
      "next" => { 'title' => 'next', 'is_link' => true, 'url' => '/?page=2' }
    }
    html = default_pagination(pagination, 'css:flickr_pagination')
    expect(html).to match(/<div class="pagination flickr_pagination">/)
    expect(html).to match(/<span class="disabled prev_page">&laquo; Previous<\/span>/)
    expect(html).to match(/<a href="\/\?page=2">2<\/a>/)
    expect(html).to match(/<span class=\"gap\">\&hellip;<\/span>/)
    expect(html).to match(/<a href="\/\?page=2" class="next_page">Next &raquo;<\/a>/)

    pagination.merge!({
      'previous' => { 'title' => 'previous', 'is_link' => true, 'url' => '/?page=4' },
      'next'     => nil
    })

    html = default_pagination(pagination, 'css:flickr_pagination')
    expect(html).to_not match(/<span class="disabled prev_page">&laquo; Previous<\/span>/)
    expect(html).to match(/<a href="\/\?page=4" class="prev_page">&laquo; Previous<\/a>/)
    expect(html).to match(/<span class="disabled next_page">Next &raquo;<\/span>/)

    pagination.merge!({ 'parts' => [] })
    html = default_pagination(pagination, 'css:flickr_pagination')
    expect(html).to eq ''
  end

end
