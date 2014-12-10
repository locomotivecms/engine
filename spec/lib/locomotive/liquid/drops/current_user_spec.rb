require 'spec_helper'

describe Locomotive::Liquid::Drops::CurrentUser do

  let(:account) { FactoryGirl.build(:admin).account }
  let(:drop)    { Locomotive::Liquid::Drops::CurrentUser.new(account) }

  describe '#logged_in?' do

    subject { render('{{ current_user.logged_in? }}') }

    it { expect(subject).to eq 'true' }

    context 'no current account' do
      let(:account) { nil }
      it { expect(subject).to eq 'false' }
    end

  end

  describe '#name' do

    subject { render('{{ current_user.name }}') }

    it { expect(subject).to eq 'Admin' }

    context 'no current account' do
      let(:account) { nil }
      it { expect(subject).to eq '' }
    end

  end

  describe '#email' do

    subject { render('{{ current_user.email }}') }

    it { expect(subject).to eq 'admin@locomotiveapp.org' }

    context 'no current account' do
      let(:account) { nil }
      it { expect(subject).to eq '' }
    end

  end

  def render(template)
    _template = Liquid::Template.parse(template)
    context = ::Liquid::Context.new({}, { 'current_user' => drop })
    _template.render(context)
  end

end
