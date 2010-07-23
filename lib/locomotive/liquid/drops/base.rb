# Code taken from Mephisto sources (http://mephistoblog.com/)
module Locomotive
  module Liquid
    module Drops
      class Base < ::Liquid::Drop

        @@forbidden_attributes = %w{_id _version _index}

        class_inheritable_reader :liquid_attributes
        write_inheritable_attribute :liquid_attributes, []
        attr_reader :source
        delegate :hash, :to => :source

        def initialize(source)
          unless source.nil?
            @source = source
            @liquid = liquid_attributes.flatten.inject({}) { |h, k| h.update k.to_s => @source.send(k) }
          end
        end

        def id
          (@source.respond_to?(:id) ? @source.id : nil) || 'new'
        end

        def before_method(method)
          @liquid[method.to_s]
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
