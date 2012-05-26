module Locomotive
  module Extensions
    module Page
      module Redirect

        extend ActiveSupport::Concern

        included do

          ## fields ##
          field :redirect,      :type => Boolean, :default => false
          field :redirect_url,  :type => String, :localize => true

          ## validations ##
          validates_presence_of :redirect_url, :if => :redirect
          validates_format_of   :redirect_url, :with => Locomotive::Regexps::URL, :allow_blank => true

        end

      end
    end
  end
end