# Monkey patch under test environment that prevents PhantomJS on OSX
# from crashing when dealing with TTF webfonts.
# Note: depending on your setup, it's likely that the RUBY_PLATFORM
# is not actually relevant for server - it's the UA that crashes.
#
# See:
#   https://github.com/jonleighton/poltergeist/issues/44
#   https://github.com/littlebtc/font-awesome-sass-rails/issues/11
#
if Rails.env.test? # && RUBY_PLATFORM =~ /darwin/
  module Sprockets::Server

    def call_with_env_instance_var(env)
      @env = env
      call_without_env_instance_var(env)
    end
    alias_method_chain :call, :env_instance_var

    def forbidden_request?(path)
      if @env['HTTP_USER_AGENT'] =~ /Intel Mac OS X.*PhantomJS/ && path =~ /ttf$/
        # STDERR.puts "Denying #{path} to #{@env['HTTP_USER_AGENT']}"
        true
      else
        path.include?("..")
      end
    end

  end
end