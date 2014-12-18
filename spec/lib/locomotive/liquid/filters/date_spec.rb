require 'spec_helper'

describe Locomotive::Liquid::Filters::Date do

  include Locomotive::Liquid::Filters::Date

  let(:timezone)  { 'Paris' }
  let(:date)      { Date.parse('2007/06/29') }
  let(:date_time) { Time.zone.parse('2007-06-29 21:35:00') }

  let(:registers) { { site: stub(timezone: timezone) } }
  let(:assigns)   { { 'today' => date } }
  let(:context)   { stub(assigns: assigns, registers: registers) }

  before(:each) { Time.zone = timezone; @context = context }

  describe '#parse_date' do

    let(:format) { nil }
    let(:input)  { '06/29/2007' }

    subject { parse_date(input, format) }

    it { is_expected.to eq date }

    describe 'with a specified format' do

      let(:format) { '%Y-%m-%d' }
      let(:input) { '2007-06-29' }

      it { is_expected.to eq date }

      describe 'but incorrect' do

        let(:format) { '%Y-%d-%m' }

        it { is_expected.to eq '' }

      end

    end

  end

  describe '#parse_date_time' do

    let(:format) { nil }
    let(:input)  { '06/29/2007 21:35:00' }

    subject { parse_date_time(input, format) }

    it { is_expected.to eq date_time }

    describe 'with a specified format' do

      let(:format) { '%Y-%d-%m %H:%M' }
      let(:input) { '2007-29-06 21:35' }

      it { is_expected.to eq date_time }

      describe 'but incorrect' do

        let(:format) { '%Y-%m-%d %H:%M' }

        it { is_expected.to eq '' }

      end

    end

  end

  describe '#distance_of_time_in_words' do

    before(:each) do
      datetime = Time.zone.parse('2012/11/25 00:00:00')
      Time.zone.stubs(:now).returns(datetime)
    end

    it 'prints the distance of time in words from a string' do
      expect(distance_of_time_in_words('2007/06/29 00:00:00')).to eq('over 5 years')
    end

    it 'prints the distance of time in words from a date' do
      expect(distance_of_time_in_words(date)).to eq('over 5 years')
    end

    it 'prints the distance of time in words with a different from_time variable' do
      expect(distance_of_time_in_words(date, '2010/11/25 00:00:00')).to eq('over 3 years')
    end

  end

  describe '#localized_date' do

    it 'prints an empty string it is nil or empty' do
      expect(localized_date(nil)).to eq('')
      expect(localized_date('')).to eq('')
    end

    it 'prints a date' do
      expect(localized_date(date)).to eq('06/29/2007')
    end

    it 'prints a date with a custom format' do
      expect(localized_date(date, '%d/%m/%Y')).to eq('29/06/2007')
    end

    it 'prints a date depending on the locale' do
      I18n.locale = 'fr'
      expect(localized_date(date)).to eq('29/06/2007')
      I18n.locale = 'en'
    end

    it 'prints a date when forcing the locale' do
      expect(localized_date(date, '%A %d %B %Y', 'fr')).to eq('vendredi 29 juin 2007')
    end

    it 'has an alias for the localized_date filter: format_date' do
      expect(format_date(date)).to eq('06/29/2007')
    end

    it 'prints a date within a template (from the documentation)' do
      template  = Liquid::Template.parse("{{ today | localized_date: '%d %B', 'fr' }}")
      context   = Liquid::Context.new({}, assigns, registers)
      expect(template.render(context)).to eq('29 juin')
    end

  end

end
