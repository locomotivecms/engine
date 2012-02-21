module Locomotive
  module Liquid
    module Drops

      class ProxyCollection < ::Liquid::Drop

        def initialize(collection)
          @collection = collection
        end

        def first
          self.collection.first
        end

        def last
          self.collection.last
        end

        def each(&block)
          self.collection.each(&block)
        end

        def each_with_index(&block)
          self.collection.each_with_index(&block)
        end

        def count
          @count ||= self.collection.count
        end

        alias :size   :count
        alias :length :count

        def empty
          self.collection.empty?
        end

        def any
          self.collection.any?
        end

        protected

        def paginate(options = {})
          @collection = collection.page(options[:page]).per(options[:per_page])
        end

        def collection
          @collection
        end

      end

    end
  end
end