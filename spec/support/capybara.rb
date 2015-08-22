def ensure_host_resolution(app_host)
  hosts = Resolv::Hosts.new
  app_host_name = URI.parse(app_host).host
  begin
    hosts.getaddress(app_host_name)
  rescue Resolv::ResolvError
    raise "Unable to resolve ip address for #{app_host_name}. Please consider adding an entry to '/etc/hosts' that associates #{app_host_name} with '127.0.0.1'."
  end
end

Capybara.configure do |config|
  config.default_selector   = :css
  config.server_port        = 9886
  config.app_host           = 'http://test.example.com:9886'

  ensure_host_resolution(config.app_host)
end

Capybara.default_wait_time = 5

Capybara.javascript_driver = :poltergeist

# Stop endless errors like
# ~/.rvm/gems/ruby-1.9.2-p0@global/gems/rack-1.2.1/lib/rack/utils.rb:16:
# warning: regexp match /.../n against to UTF-8 string
# more information here: https://github.com/jnicklas/capybara/issues/243
$VERBOSE = nil
