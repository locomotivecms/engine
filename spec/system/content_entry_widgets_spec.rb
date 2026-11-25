# Drives the jQuery widgets of the content entry form (bootstrap-switch, datetimepicker + moment,
# tagsinput, colorpicker, CodeMirror markdown, select2) and checks what gets saved.
RSpec.shared_context 'widgets content type' do
  before do
    create_full_site
    @widgets = @site.content_types.build(name: 'Widgets', slug: 'widgets').tap do |ct|
      ct.entries_custom_fields.build label: 'Title',     name: 'title',     type: 'string'
      ct.entries_custom_fields.build label: 'Featured',  name: 'featured',  type: 'boolean'
      ct.entries_custom_fields.build label: 'Starts on', name: 'starts_on', type: 'date'
      ct.entries_custom_fields.build label: 'Tags',      name: 'tags',      type: 'tags'
      ct.entries_custom_fields.build label: 'Colour',    name: 'colour',    type: 'color'
      ct.entries_custom_fields.build label: 'Notes',     name: 'notes',     type: 'text', text_formatting: 'markdown'
      category = ct.entries_custom_fields.build label: 'Category', name: 'category', type: 'select'
      category.select_options.build name: 'Development', position: 0
      category.select_options.build name: 'Design', position: 1
      ct.save!
    end
  end
end

describe 'Content entry widgets', js: true do

  include_context 'widgets content type'

  it 'saves what the widgets produce' do
    visit "/locomotive/#{@site.handle}/content_types/widgets/entries/new"

    fill_in 'Title', with: 'Widget test'

    # bootstrap-switch
    find('.input.toggle .bootstrap-switch').click
    expect(page).to have_css('.input.toggle .bootstrap-switch-on')

    # datetimepicker (moment parses/format the value)
    find('.input.date input[type=text]').click
    within('.bootstrap-datetimepicker-widget') { find('td.day:not(.old):not(.new)', text: /\A15\z/).click }
    expect(find('.input.date input[type=text]').value).to include('15')

    # tagsinput
    find('.input.tags .bootstrap-tagsinput input').send_keys('alpha', :enter)
    expect(page).to have_css('.input.tags .tag', text: 'alpha')

    # colorpicker
    find('.input.color .input-group-addon').click
    expect(page).to have_css('.colorpicker', visible: true)
    find('.input.color input').set('#ff0000')

    # CodeMirror (markdown)
    find('.input.markdown .CodeMirror').click
    page.driver.browser.action.send_keys('**bold**').perform
    expect(page).to have_css('.input.markdown .CodeMirror', text: '**bold**')

    # select2
    find('.input.select .select2-selection').click
    find('.select2-results__option', text: 'Design').click
    expect(page).to have_css('.input.select .select2-selection__rendered', text: 'Design')

    expect(page).to have_no_javascript_error

    within('#main') { click_button 'Create' }
    expect(page).to have_content('Entry was successfully created.')

    entry = @widgets.reload.entries.last
    expect(entry.title).to eq 'Widget test'
    expect(entry.featured).to eq true
    expect(entry.starts_on.day).to eq 15
    expect(entry.tags).to eq ['alpha']
    expect(entry.colour).to eq '#ff0000'
    expect(entry.notes).to eq '**bold**'
    expect(entry.category).to eq 'Design'
    expect(page).to have_no_javascript_error
  end

end
