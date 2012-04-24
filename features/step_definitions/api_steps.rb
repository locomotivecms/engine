
def api_base_url
  "http://#{@site.domains.first}/locomotive/api/"
end

def do_api_request(type, url, param_string = nil)
  begin
    params = param_string && JSON.parse(param_string) || {}
    @json_response = do_request(type, api_base_url, url,
                               params.merge({ 'CONTENT_TYPE' => 'application/json' }))
  rescue Exception
    @error = $!
  end
end

def last_json
  @json_response.try(:body) || page.source
end

def parsed_response
  @parsed_response ||= JSON.parse(last_json)
end

Given /^I have an? "([^"]*)" API token$/ do |role|
  @membership = Locomotive::Site.first.memberships.where(:role => role.downcase).first \
    || FactoryGirl.create(role.downcase.to_sym, :site => Locomotive::Site.first)

  login_params = {
    'email'     => @membership.account.email,
    'password'  => 'easyone'
  }

  response = do_request('POST', api_base_url, 'tokens.json',
                        login_params.merge({ 'CONTENT_TYPE' => 'application/json' }))

  if response.status == 200
    @auth_token = JSON.parse(response.body)['token']
  else
    raise JSON.parse(response.body)['message']
  end

  add_default_params(:auth_token => @auth_token)
end

Given /^I do not have an API token$/ do
  @auth_token = nil
end

When /^I visit "([^"]*)"$/ do |path|
  @json_response = get("http://#{@site.domains.first}#{path}", { auth_token: @auth_token }, { 'CONTENT_TYPE' => 'application/json' })
end

# http://stackoverflow.com/questions/9009392/racktest-put-method-with-json-fails-to-convert-json-to-params
When /^I post to "([^"]*)"$/ do |path|
  @json_response = post("http://#{@site.domains.first}#{path}", '', { 'CONTENT_TYPE' => 'application/json' })
end

When /^I post to "([^"]*)" with:$/ do |path, json_string|
  @json_response = post("http://#{@site.domains.first}#{path}", json_string, { 'CONTENT_TYPE' => 'application/json' })
end

When /^I do an API (\w+) (?:request )?to ([\w.\/]+)$/ do |request_type, url|
  do_api_request(request_type, url)
end

When /^I do an API (\w+) (?:request )?to ([\w.\/]+) with:$/ do |request_type, url, param_string|
  do_api_request(request_type, url, param_string)
end

Then /^the JSON response should contain all pages$/ do
  page_ids_in_response = parsed_response.collect { |page| page['id'].to_s }.sort
  all_page_ids = Locomotive::Page.all.collect { |page| page.id.to_s }.sort
  page_ids_in_response.should == all_page_ids
end

Then /^the JSON response should contain (\d+) pages$/ do |n|
  parsed_response.count.should == n.to_i
end

Then /^an access denied error should occur$/ do
  @error.should_not be_nil
  @error.message.should == 'You are not authorized to access this page.'
end

=begin
Then /^the JSON response hash should contain:$/ do |json|
  sub_response = {}
  parsed_json = JSON.parse(json)
  parsed_json.each do |k, v|
    sub_response[k] = @response[k]
  end
  sub_response.should == parsed_json
end
=end
