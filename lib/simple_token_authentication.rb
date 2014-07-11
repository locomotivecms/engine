require_relative 'simple_token_authentication/acts_as_token_authenticable'

# TODO use of safe mode (requires to send email in authentication request)
# @see https://gist.github.com/josevalim/fb706b1e933ef01e4fb6
require_relative 'simple_token_authentication/unsafe/acts_as_token_authentication_handler'
#require_relative 'simple_token_authentication/safe/acts_as_token_authentication_handler'
