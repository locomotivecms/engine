module Locomotive
  module Mongoid

    module Presenter

      extend ActiveSupport::Concern

      included do
        # keep a link to the original as_json method from Mongoid
        alias :as_json_from_mongoid :as_json

        # keeps track of the presenter class
        class << self; attr_writer :presenter_class end
      end

      # Get the presenter corresponding to the current document
      #
      # @return [ Object ] The presenter
      #
      def to_presenter(options = {})
        return nil unless self.class.presenter_class
        self.class.presenter_class.new(self, options)
      end

      # Set the attributes of the document by using
      # the corresponding presenter.
      #
      # @param [ Hash ] attributes The document attributes
      #
      def from_presenter(attributes = {})
        self.to_presenter.attributes = attributes
      end

      def as_json(options = {})
        if presenter = self.to_presenter(options)
          presenter.as_json
        else
          self.as_json_from_mongoid(options)
        end
      end

      module ClassMethods

        # Return the memoized presenter class if it exists.
        #
        # @return [ Class ] The presenter class
        #
        def presenter_class
          return @presenter_class if @presenter_class
          _name             = "Locomotive::#{name.demodulize}Presenter"
          @presenter_class  = _name.constantize rescue nil
        end

        # Initialize an instance of the document by passing
        # attributes calculated by the associated presenter.
        #
        # @param [ Hash ] attributes The document attributes
        #
        # @return [ Object ] A new document instance filled with the parameters
        #
        def from_presenter(attributes)
          new.tap do |document|
            presenter = document.to_presenter
            presenter.attributes = attributes
          end
        end

      end

    end

  end
end
