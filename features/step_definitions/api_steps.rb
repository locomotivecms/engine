
def api_base_url
  "http://#{Locomotive::Site.first.domains.first}/locomotive/api/"
end

def do_api_request(type, url, param_string_or_hash = nil)
  begin
    if param_string_or_hash
      if param_string_or_hash.is_a? Hash
        params = param_string_or_hash
      else
        params = JSON.parse(param_string_or_hash)
      end
    else
      params = {}
    end
    @json_response = do_request(type, api_base_url, url,
                               params.merge({ 'CONTENT_TYPE' => 'application/json' }))
  rescue CanCan::AccessDenied, Mongoid::Errors::DocumentNotFound
    @error = $!
  end
end

def last_json
  @json_response.try(:body) || page.source
end

def last_status
  @json_response.try(:status) || page.status
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

Then /^an access denied error should occur$/ do
  if @error
    @error.is_a?(CanCan::AccessDenied).should be_true
  else
    last_status.should == 401
  end
end

Then /^it should not exist$/ do
  if @error
    @error.is_a?(Mongoid::Errors::DocumentNotFound).should be_true
  else
    last_status.should == 404
  end
end

When /^I do a multipart API (\w+) (?:request )?to ([\w.\/]+) with base key "([^"]*)" and:$/ \
    do |request_type, url, base_key, table|
  params = {}
  params = table.rows_hash
  params.each do |key, filename|
    params[key] = Rack::Test::UploadedFile.new(Rails.root.join('..', 'fixtures', filename))
  end
  do_api_request(request_type, url, { base_key => params })
end

Then /^I print the json response$/ do
  puts %{JSON: "#{last_json}" / #{last_json.inspect}}
end
