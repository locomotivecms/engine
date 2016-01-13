module Locomotive
  module Concerns
    module Page
      module Redirect

        extend ActiveSupport::Concern

        included do

          ## fields ##
          field :redirect,      type: Boolean, default:  false
          field :redirect_url,  type: String,  localize: true, default: ''
          field :redirect_type, type: Integer, default:  301

          ## validations ##
          validates_presence_of :redirect_type, if: :redirect?
          validates_presence_of :redirect_url,  if: :redirect?
          validates_format_of   :redirect_url,  with: Locomotive::Regexps::URL_AND_MAILTO, allow_blank: true

        end

      end
    end
  end
end
