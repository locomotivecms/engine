# Opens every back-office screen (and the public preview) of a full site and
# collects the browser console errors, so JS regressions show up in CI.
describe 'Browser console', js: true do

  let(:errors) { {} }

  before do
    # the browser log survives between examples; drop what earlier specs left behind
    Features::Matchers::HaveNoJavascriptError.errors(page)
    check('setup (sign in, create site)') { create_full_site }
  end

  def check(label)
    yield if block_given?
    # wait for the page and its ajax calls to settle before reading the console
    Timeout.timeout(Capybara.default_max_wait_time) do
      sleep 0.1 until evaluate_script("document.readyState === 'complete' && (!window.jQuery || jQuery.active === 0)")
    end
    found = Features::Matchers::HaveNoJavascriptError.errors(page).map(&:message)
    errors[label] = found if found.any?
  end

  def site_path(path = '')
    "/locomotive/#{@site.handle}/#{path}"
  end

  it 'shows no errors on any screen' do
    contact = @site.pages.where(slug: 'contact').first
    hello   = @site.pages.where(slug: 'hello-world').first
    article = @site.content_types.where(slug: 'articles').first.entries.create!(title: 'Hello')

    {
      'sites'                => '/locomotive/sites',
      'new site'             => '/locomotive/sites/new',
      'my account'           => '/locomotive/my_account/edit',
      'dashboard'            => site_path('dashboard'),
      'new page'             => site_path('pages/new'),
      'edit page settings'   => site_path("pages/#{contact._id}/edit"),
      'editable elements'    => site_path("pages/#{contact._id}/editable_elements"),
      'articles'             => site_path('content_types/articles/entries'),
      'new article'          => site_path('content_types/articles/entries/new'),
      'edit article'         => site_path("content_types/articles/entries/#{article._id}/edit"),
      'photos'               => site_path('content_types/photos/entries'),
      'new photo'            => site_path('content_types/photos/entries/new'),
      'messages'             => site_path('content_types/messages/entries'),
      'import entries'       => site_path('content_types/articles/imports/new'),
      'content assets'       => site_path('content_assets'),
      'translations'         => site_path('translations'),
      'site settings'        => site_path('current_site/edit'),
      'site metafields'      => site_path('current_site_metafields'),
      'new membership'       => site_path('memberships/new'),
      'developers'           => site_path('developers'),
      'preview home'         => site_path('preview/'),
      'preview contact'      => site_path('preview/contact'),
      'preview sections'     => site_path('preview/hello-world')
    }.each do |label, path|
      check(label) { visit path }
    end

    # the sections editor is a React app inside the back-office; open it and each section
    check('sections editor') do
      visit site_path("pages/#{hello._id}/content/edit")
      expect(page).to have_content('/hello-world')
    end
    ['This is the header', 'Gallery'].each do |section|
      check("sections editor: open #{section}") do
        find(:link, text: /\A#{Regexp.escape(section)}\z/i).click # labels are uppercased with CSS
        expect(page).to have_no_link(text: /\Athis is the header\z/i) # the section list is replaced by its settings
      end
      check("sections editor: back from #{section}") do
        visit site_path("pages/#{hello._id}/content/edit")
        expect(page).to have_content('/hello-world')
      end
    end
    %w(Settings SEO).each do |tab|
      check("sections editor: #{tab} tab") { find("a", text: /\A#{tab}\z/i).click } # tabs are <a> without href
    end

    expect(errors).to be_empty, -> { "browser console errors:\n" + errors.map { |page, msgs| "  #{page}:\n" + msgs.map { |m| "    - #{m}" }.join("\n") }.join("\n") }
  end

end
