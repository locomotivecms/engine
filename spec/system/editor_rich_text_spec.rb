# The rich text setting of a section (draft-js / react-draft-wysiwyg inside the editor).
describe 'Editing a rich text setting of a section', js: true do

  before do
    create_full_site
    create(:section, site: @site, name: 'Intro', slug: 'intro',
      template: %{<div class="intro">{{ section.settings.body }}</div>},
      definition: { name: 'intro', settings: [{ label: 'Body', id: 'body', type: 'text', html: true }], blocks: [] })
    @intro = @site.pages.create!(
      parent: @site.pages.root.first, title: 'Intro page', slug: 'intro-page',
      raw_template: %{<html><head></head><body>{% section 'intro' %}</body></html>},
      sections_content: { intro: { settings: { body: '<p>Hello</p>' } } }
    )
  end

  it 'makes text bold and saves the HTML' do
    visit "/locomotive/#{@site.handle}/pages/#{@intro._id}/content/edit"
    expect(page).to have_content('/intro-page')
    find(:link, text: /\Ahello\z/i).click # the section is labelled by its first text setting

    editor = find('.public-DraftEditor-content')
    editor.click
    editor.send_keys([RUBY_PLATFORM.include?('darwin') ? :command : :control, 'a']) # select all
    find('.rdw-option-wrapper[title="Bold"]').click
    editor.send_keys(:end, ' world')
    expect(page).to have_css('.public-DraftEditor-content', text: 'Hello world')

    click_button 'Save'
    expect(page).to have_no_button('Saving...', wait: 10)

    body = Locomotive::Page.find(@intro._id).sections_content.dig('intro', 'settings', 'body')
    expect(body).to include('<strong>')
    expect(body).to include('Hello')
    expect(body).to include('world')
    expect(page).to have_no_javascript_error
  end

end
