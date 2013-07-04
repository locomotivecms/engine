require 'spec_helper'

describe Locomotive::Liquid::Filters::Misc do

  include Locomotive::Liquid::Filters::Base
  include Locomotive::Liquid::Filters::Misc

  it 'returns the input string every n occurences' do
    str_modulo('foo', 0, 3).should == ''
    str_modulo('foo', 1, 3).should == ''
    str_modulo('foo', 2, 3).should == 'foo'
    str_modulo('foo', 3, 3).should == ''
    str_modulo('foo', 4, 3).should == ''
    str_modulo('foo', 5, 3).should == 'foo'
  end

  it 'returns default values if the input is empty' do
    default('foo', 42).should == 'foo'
    default('', 42).should == 42
    default(nil, 42).should == 42
  end

  describe 'random' do

    context 'from an integer' do

      subject { random(4) }
      it { should be_a_kind_of(Fixnum) }
      it { should satisfy { |n| n >=0 && n < 4 } }

    end

    context 'from a string' do

      subject { random('4') }
      it { should be_a_kind_of(Fixnum) }
      it { should satisfy { |n| n >=0 && n < 4 } }

    end

  end

  it 'returns a random number' do
    random_number = random(4)
    random_number.class.should == Fixnum

  end

  it 'should return a navigation block for the pagination' do
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
    html.should match(/<div class="pagination flickr_pagination">/)
    html.should match(/<span class="disabled prev_page">&laquo; Previous<\/span>/)
    html.should match(/<a href="\/\?page=2">2<\/a>/)
    html.should match(/<span class=\"gap\">\&hellip;<\/span>/)
    html.should match(/<a href="\/\?page=2" class="next_page">Next &raquo;<\/a>/)

    pagination.merge!({
      'previous' => { 'title' => 'previous', 'is_link' => true, 'url' => '/?page=4' },
      'next'     => nil
    })

    html = default_pagination(pagination, 'css:flickr_pagination')
    html.should_not match(/<span class="disabled prev_page">&laquo; Previous<\/span>/)
    html.should match(/<a href="\/\?page=4" class="prev_page">&laquo; Previous<\/a>/)
    html.should match(/<span class="disabled next_page">Next &raquo;<\/span>/)

    pagination.merge!({ 'parts' => [] })
    html = default_pagination(pagination, 'css:flickr_pagination')
    html.should == ''
  end

end
