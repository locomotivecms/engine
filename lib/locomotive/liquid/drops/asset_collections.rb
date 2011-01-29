module Locomotive
  module Liquid
    module Drops

      class AssetCollections < ::Liquid::Drop

        def before_method(meth)
          collection = @context.registers[:site].asset_collections.where(:slug => meth.to_s).first
          AssetCollectionProxy.new(collection)
        end

      end

      class AssetCollectionProxy < ::Liquid::Drop

        def initialize(collection)
          @collection = collection
        end

        def first
          @collection.ordered_assets.first
        end

        def last
          @collection.ordered_assets.last
        end

        def each(&block)
          @collection.ordered_assets.each(&block)
        end

        def paginate(options = {})
          paginated_collection = @collection.ordered_assets.paginate(options)
          {
            :collection       => paginated_collection,
            :current_page     => paginated_collection.current_page,
            :previous_page    => paginated_collection.previous_page,
            :next_page        => paginated_collection.next_page,
            :total_entries    => paginated_collection.total_entries,
            :total_pages      => paginated_collection.total_pages,
            :per_page         => paginated_collection.per_page
          }
        end

        def size
          @collection.assets.size
        end

        def before_method(meth)
          return '' if @collection.nil?
          @collection.send(meth)
        end

      end

    end
  end
end
