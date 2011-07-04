# Liquify taken from Mephisto sources (http://mephistoblog.com/)
module Locomotive
  module Liquid
    module Drops
      class Base < ::Liquid::Drop

        @@forbidden_attributes = %w{_id _version _index}

        attr_reader :_source

        def initialize(source)
          @_source = source
        end

        def id
          (@_source.respond_to?(:id) ? @_source.id : nil) || 'new'
        end

        # converts an array of records to an array of liquid drops
        def self.liquify(*records, &block)
          i = -1
          records =
            records.inject [] do |all, r|
              i+=1
              attrs = (block && block.arity == 1) ? [r] : [r, i]
              all << (block ? block.call(*attrs) : r.to_liquid)
              all
            end
          records.compact!
          records
        end

        protected

        def liquify(*records, &block)
          self.class.liquify(*records, &block)
        end

      end
    end
  end
end
