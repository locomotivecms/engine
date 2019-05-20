require 'spec_helper'

describe Locomotive::Shared::SiteMetafieldsHelper do

  let(:ui)            { { 'label' => 'Store settings', 'hint' => 'Lorem ipsum', 'icon' => 'shopping-cart' } }
  let(:current_site)  { build(:site, metafields_ui: ui) }

  subject { current_site_metafields_ui }

  it { expect(subject[:label]).to eq 'Store settings' }
  it { expect(subject[:title]).to eq 'Store settings' }
  it { expect(subject[:hint]).to eq 'Lorem ipsum' }
  it { expect(subject[:icon]).to eq 'fas fa-shopping-cart' }

  describe 'no ui' do

    let(:ui) { {} }

    it { expect(subject[:label]).to eq 'Properties' }
    it { expect(subject[:title]).to eq 'Editing properties' }
    it { expect(subject[:hint]).to eq '' }
    it { expect(subject[:icon]).to eq 'fas fa-newspaper' }

  end

  describe 'localized' do

    let(:ui) { { 'label' => { 'default' => 'Store settings', 'fr' => 'Paramètres e-commerce' } } }

    it { expect(subject[:label]).to eq 'Store settings' }

    it 'renders the label in a different locale' do
      I18n.with_locale(:fr) do
        expect(subject[:label]).to eq 'Paramètres e-commerce'
      end
    end

    it 'renders the default label in an unkown locale' do
      I18n.with_locale(:de) do
        expect(subject[:label]).to eq 'Store settings'
      end
    end

  end

end

