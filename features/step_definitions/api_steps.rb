
def new_content_page(page_slug, page_contents = '', template = '')
  @home = @site.pages.where(:slug => 'index').first || FactoryGirl.create(:page)
  page = @site.pages.build(:slug => page_slug, :body => page_contents, :parent => @home, :title => "some title", :published => true, :raw_template => template)
  page.should be_valid
  page
end

def api_base_url
  '/locomotive/api'
end

def do_api_request(type, url, param_string = nil)
  params = param_string && JSON.parse(param_string) || {}
  @raw_response = do_request(type, api_base_url, url, params)
  @response = JSON.parse(@raw_response.body)
end

Given /^a page named "([^"]*)" with id "([^"]*)"$/ do |name, id|
  @page = new_content_page(name)
  @page.id = BSON::ObjectId(id)
  @page.save!
end

Given /^I have an? "([^"]*)" token$/ do |role|
  @membership = Locomotive::Site.first.memberships.where(:role => role.downcase).first \
    || FactoryGirl.create(role.downcase.to_sym, :site => Locomotive::Site.first)

  login_params = {
    :email => @membership.account.email,
    :password => 'easyone'
  }
  response = do_request('POST', api_base_url, 'tokens.json', login_params)

  if response.status == 200
    @token = JSON.parse(response.body)['token']
  else
    raise JSON.parse(response.body)['message']
  end

  add_default_params(:auth_token => @token)
end

When /^I do an API (\w+) (?:request )?to ([\w.\/]+)$/ do |request_type, url|
  do_api_request(request_type, url)
end

When /^I do an API (\w+) (?:request )?to ([\w.\/]+) with:$/ do |request_type, url, param_string|
  do_api_request(request_type, url, param_string)
end

Then /^the JSON response should be the following:$/ do |json|
  @response.should == JSON.parse(json)
end

Then /^the JSON response should contain all pages$/ do
  page_ids_in_response = @response.collect { |page| page['id'].to_s }.sort
  all_page_ids = Locomotive::Page.all.collect { |page| page.id.to_s }.sort
  page_ids_in_response.should == all_page_ids
end

Then /^the JSON response should contain (\d+) pages$/ do |n|
  @response.count.should == n.to_i
end

Then /^the JSON response should be an access denied error$/ do
  @response['message'].should == 'You are not authorized to access this page'
end

Then /^the JSON response should contain:$/ do |json|
  @response.merge(JSON.parse(json)).should == @response
end
