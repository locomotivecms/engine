require 'spec_helper'

describe Locomotive::Liquid::Filters::Date do

  include Locomotive::Liquid::Filters::Date

  before(:each) do
    Time.zone = 'Paris'
    @date       = Date.parse('2007/06/29')
    @date_time  = Time.zone.parse('2007-06-29 21:35:00')
  end

  describe '#parse_date' do

    let(:format) { nil }
    let(:input)  { '06/29/2007' }

    subject { parse_date(input, format) }

    it { should == @date }

    describe 'with a specified format' do

      let(:format) { '%Y-%m-%d' }
      let(:input) { '2007-06-29' }

      it { should == @date }

      describe 'but incorrect' do

        let(:format) { '%Y-%d-%m' }

        it { should == '' }

      end

    end

  end

  describe '#parse_date_time' do

    let(:format) { nil }
    let(:input)  { '06/29/2007 21:35:00' }

    subject { parse_date_time(input, format) }

    it { should == @date_time }

    describe 'with a specified format' do

      let(:format) { '%Y-%d-%m %H:%M' }
      let(:input) { '2007-29-06 21:35' }

      it { should == @date_time }

      describe 'but incorrect' do

        let(:format) { '%Y-%m-%d %H:%M' }

        it { should == '' }

      end

    end

  end

  describe '#distance_of_time_in_words' do

    before(:each) do
      datetime = Time.zone.parse('2012/11/25 00:00:00')
      Time.zone.stubs(:now).returns(datetime)
    end

    it 'prints the distance of time in words from a string' do
      distance_of_time_in_words('2007/06/29 00:00:00').should == 'over 5 years'
    end

    it 'prints the distance of time in words from a date' do
      distance_of_time_in_words(@date).should == 'over 5 years'
    end

    it 'prints the distance of time in words with a different from_time variable' do
      distance_of_time_in_words(@date, '2010/11/25 00:00:00').should == 'over 3 years'
    end

  end

  describe '#localized_date' do

    it 'prints an empty string it is nil or empty' do
      localized_date(nil).should == ''
      localized_date('').should == ''
    end

    it 'prints a date' do
      localized_date(@date).should == '06/29/2007'
    end

    it 'prints a date with a custom format' do
      localized_date(@date, '%d/%m/%Y').should == '29/06/2007'
    end

    it 'prints a date depending on the locale' do
      I18n.locale = 'fr'
      localized_date(@date).should == '29/06/2007'
      I18n.locale = 'en'
    end

    it 'prints a date when forcing the locale' do
      localized_date(@date, '%A %d %B %Y', 'fr').should == 'vendredi 29 juin 2007'
    end

    it 'has an alias for the localized_date filter: format_date' do
      format_date(@date).should == '06/29/2007'
    end

    it 'prints a date within a template (from the documentation)' do
      template  = Liquid::Template.parse("{{ today | localized_date: '%d %B', 'fr' }}")
      context   = Liquid::Context.new({}, { 'today' => @date }, {})
      template.render(context).should == '29 juin'
    end

  end

end