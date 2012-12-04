Given %r{^I have an? "([^"]*)" model which has many "([^"]*)"$} do |parent_model, child_model|
  @parent_model = FactoryGirl.build(:content_type, :site => @site, :name => parent_model).tap do |ct|
    ct.entries_custom_fields.build :label => 'Body', :type => 'string', :required => false
    ct.save!
  end
  @child_model = FactoryGirl.build(:content_type, :site => @site, :name => child_model).tap do |ct|
    ct.entries_custom_fields.build :label => 'Body', :type => 'string', :required => false
    ct.entries_custom_fields.build :label => parent_model.singularize.downcase, :type => 'belongs_to', :required => false, :class_name => @parent_model.entries_class_name
    ct.save!
  end

  @parent_model.entries_custom_fields.build({
    :label          => child_model,
    :type           => 'has_many',
    :class_name     => @child_model.entries_class_name,
    :inverse_of     => parent_model.singularize.downcase
  })

  @parent_model.save
end

Given %r{^I set up a has_many relationship between "([^"]*)" and "([^"]*)"$} do |source_name, target_name|
  source_model = @site.content_types.where(:name => source_name).first
  target_model = @site.content_types.where(:name => target_name).first

  source_model.entries_custom_fields.build({
    :label          => target_name,
    :type           => 'has_many',
    :class_name     => target_model.entries_class_name,
    :inverse_of     => source_name.singularize.downcase
  })

  source_model.save
end

Given %r{^I set up a many_to_many relationship between "([^"]*)" and "([^"]*)"$} do |first_name, last_name|
  first_model = @site.content_types.where(:name => first_name).first
  last_model  = @site.content_types.where(:name => last_name).first

  first_model.entries_custom_fields.build({
    :label          => last_name,
    :type           => 'many_to_many',
    :class_name     => last_model.entries_class_name,
    :inverse_of     => first_name.pluralize.downcase
  })

  first_model.save

  last_model.entries_custom_fields.build({
    :label          => first_name,
    :type           => 'many_to_many',
    :class_name     => first_model.entries_class_name,
    :inverse_of     => last_name.pluralize.downcase
  })

  last_model.save
end

Given %r{^I attach the "([^"]*)" ([\S]*) to the "([^"]*)" ([\S]*)$} do |target_name, target_model_name, souce_name, source_model_name|
  target_model  = @site.content_types.where(:name => target_model_name.pluralize.capitalize).first
  source_model  = @site.content_types.where(:name => source_model_name.pluralize.capitalize).first

  target_entry = target_model.entries.where(:_slug => target_name.permalink).first
  source_entry = source_model.entries.where(:_slug => souce_name.permalink).first

  source_entry.send(target_model_name.pluralize.downcase.parameterize('_').to_sym).push(target_entry)
end

Then /^I should be able to view a paginated list of a has many association$/ do
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
  FactoryGirl.create(:page, :site => @site, :slug => 'hello', :parent => @site.pages.root.first, :raw_template => raw_template)

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
