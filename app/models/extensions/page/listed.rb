module Extensions
  module Page
    module Listed

      extend ActiveSupport::Concern

      included do

        field :listed, :type => Boolean, :default => true

      end

    end
  end
end