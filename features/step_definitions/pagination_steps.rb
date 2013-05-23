Then /^I should be able to display paginated models$/ do
  # Create our article model and three articles
  @article_model = FactoryGirl.build(:content_type, site: @site, name: 'Articles', order_by: '_position').tap do |ct|
    ct.entries_custom_fields.build label: 'Body', type: 'string', required: false
    ct.save!
  end

  %w(First Second Third).each do |body|
    @article_model.entries.create!(body: body)
  end

  # Create a page with template
  raw_template = %{
  {% paginate contents.articles by 2 %}
    {% for article in paginate.collection %}
      {{ article.body }}
    {% endfor %}
    {{ paginate | default_pagination }}
  {% endpaginate %}
  }
  FactoryGirl.create(:page, site: @site, slug: 'hello', parent: @site.pages.root.first, raw_template: raw_template)

  # The page should have the first two articles
  visit '/hello'
  page.should have_content 'First'
  page.should have_content 'Second'
  page.should_not have_content 'Third'

  # The second page should have the last article
  click_link '2'
  page.should_not have_content 'First'
  page.should_not have_content 'Second'
  page.should     have_content 'Third'
end

