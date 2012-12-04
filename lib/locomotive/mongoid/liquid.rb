module Locomotive
  module Mongoid

    module Liquid

      extend ActiveSupport::Concern

      included do
        # keeps track of the liquid drop class
        class << self; attr_writer :drop_class  end
      end

      # Get the liquid drop corresponding to the current document
      #
      # @return [ Object ] The liquid drop
      #
      def to_liquid
        return nil unless self.class.drop_class
        self.class.drop_class.new(self)
      end

      module ClassMethods

        # Return the memoized liquid drop class if it exists.
        #
        # @return [ Class ] The liquid drop class
        #
        def drop_class
          return @drop_class if @drop_class
          _name       = "Locomotive::Liquid::Drops::#{name.demodulize}"
          @drop_class = _name.constantize rescue nil
        end

      end

    end

  end
end
