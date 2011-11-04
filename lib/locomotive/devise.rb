# require 'devise/mailers/helpers'

# puts Devise.warden_config.inspect

# monkey patch to let Devise know about custom Locomotive mailer views
# module Devise
#   module Mailers
#     module Helpers
#
#       included do
#         include Devise::Controllers::ScopedViews
#         include Locomotive::Engine.routes.url_helpers
#         attr_reader :scope_name, :resource
#       end
#
#       def template_paths_with_locomotive
#         template_path = self.template_paths_without_locomotive
#
#         if self.class.scoped_views?
#           scoped_path = @devise_mapping.scoped_path
#           scoped_path = 'locomotive' if scoped_path =~ /^locomotive_/
#           template_path.unshift "#{scoped_path}/mailer"
#         end
#
#         template_path
#       end
#
#       alias_method_chain :template_paths, :locomotive
#     end
#   end
# end

