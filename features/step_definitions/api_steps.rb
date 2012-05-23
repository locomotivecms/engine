def last_json
  @json_response.try(:body) || page.source
end

Given /^I have an? "([^"]*)" API token$/ do |role|
  @membership = Locomotive::Site.first.memberships.where(:role => role.downcase).first \
    || FactoryGirl.create(role.downcase.to_sym, :site => Locomotive::Site.first)

  login_params = {
    'email'     => @membership.account.email,
    'password'  => 'easyone'
  }

  response = post("http://#{@site.domains.first}/locomotive/api/tokens.json", login_params.to_json, { 'CONTENT_TYPE' => 'application/json' })

  if response.status == 200
    @auth_token = JSON.parse(response.body)['token']
  else
    raise JSON.parse(response.body)['message']
  end
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