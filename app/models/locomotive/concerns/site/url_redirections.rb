module Locomotive
  module Concerns
    module Site
      module UrlRedirections

        extend ActiveSupport::Concern

        included do

          ## fields ##
          field :url_redirections, type: Array

        end

        def url_redirections=(array)
          super((array || []).flatten.map do |path|
            add_leading_slash_to(path)
          end.each_slice(2).to_a)
        end

        protected

        def add_leading_slash_to(path)
          path.starts_with?('/') ? path : "/#{path}"
        end

      end
    end
  end
end
