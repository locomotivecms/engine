Given %r{^I have an? "([^"]*)" model which has many "([^"]*)"$} do |parent_model, child_model|
  @parent_model = FactoryGirl.build(:content_type, :site => @site, :name => parent_model).tap do |ct|
    ct.entries_custom_fields.build :label => 'Body', :type => 'string', :required => false
    ct.save!
  end
  @child_model = FactoryGirl.build(:content_type, :site => @site, :name => child_model).tap do |ct|
    ct.entries_custom_fields.build :label => 'Body', :type => 'string', :required => false
    ct.entries_custom_fields.build :label => parent_model.singularize.downcase, :type => 'belongs_to', :required => false, :class_name => @parent_model.klass_with_custom_fields(:entries).to_s
    ct.save!
  end

  @parent_model.entries_custom_fields.build({
    :label          => child_model,
    :type           => 'has_many',
    :class_name     => @child_model.klass_with_custom_fields(:entries).to_s,
    :inverse_of     => parent_model.singularize.downcase
  })
  @parent_model.save
end

Then /^I should be able to view a paginaed list of a has many association$/ do
  # Create models
  step %{I have an "Articles" model which has many "Comments"}

  # Create contents
  article = @parent_model.entries.create!(:slug => 'parent', :body => 'Parent')
  @child_model.entries.create!(:slug => 'one', :body => 'One', :article => article)
  @child_model.entries.create!(:slug => 'two', :body => 'Two', :article => article)
  @child_model.entries.create!(:slug => 'three', :body => 'Three', :article => article)

  # Create a page
  raw_template = %{
  {% for article in models.articles %}
    {{ article.body }}
    {% paginate article.comments by 2 %}
      {% for comment in paginate.collection %}
        {{ comment.body }}
      {% endfor %}
      {{ paginate | default_pagination }}
    {% endpaginate %}
  {% endfor %}
  }

  # Create a page
  FactoryGirl.create(:page, :site => @site, :slug => 'hello', :raw_template => raw_template)

  # The page should have the first two comments
  visit '/hello'

  page.should have_content 'One'
  page.should have_content 'Two'
  page.should_not have_content 'Three'

  # The second page should have the last comment
  click_link '2'
  page.should_not have_content 'One'
  page.should_not have_content 'Two'
  page.should     have_content 'Three'
end
