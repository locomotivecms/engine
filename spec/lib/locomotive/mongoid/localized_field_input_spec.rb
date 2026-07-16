require 'rails_helper'

describe 'Localized field form input' do

  let(:site) { create(:site, locales: %w(en fr)) }
  let(:view) { ActionView::Base.new(ActionController::Base.view_paths, {}, nil) }

  def rendered_title_input(page, locale)
    Mongoid::Fields::I18n.with_locale(locale) do
      view.text_field(:page, :title, object: page)
    end
  end

  it 'renders the value translated to the current locale' do
    page = create(:page, site: site)
    Mongoid::Fields::I18n.with_locale(:en) { page.title = 'Hello' }
    Mongoid::Fields::I18n.with_locale(:fr) { page.title = 'Bonjour' }
    page.save!

    expect(rendered_title_input(page, :en)).to include('value="Hello"')
    expect(rendered_title_input(page, :fr)).to include('value="Bonjour"')
  end

end
