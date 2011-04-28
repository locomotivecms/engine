# encoding: utf-8

require 'mongoid'

# Limit feature for embedded documents

module Mongoid #:nodoc:
  module Criterion #:nodoc:
    module Exclusion

      def only(*args)
        clone.tap do |crit|
          crit.options[:fields] ||= {}
          crit.options[:fields][:only] = args.flatten if args.any?
        end
      end

    end

    module Optional

      # Adds a criterion to the +Criteria+ that specifies the maximum number of
      # results to return. This is mostly used in conjunction with <tt>skip()</tt>
      # to handle paginated results.
      #
      # Options:
      #
      # value: An +Integer+ specifying the max number of results. Defaults to 20.
      # hash: A +Hash+ specifying the max number of results for the embedded collections.
      #
      # Example:
      #
      # <tt>criteria.limit(100)</tt>
      # <tt>criteria.limit(100, { :contents => 5 })</tt>
      # <tt>criteria.limit(:contents => 5)</tt>
      #
      # Returns: <tt>self</tt>
      def limit(*args)
        clone.tap do |crit|
          arguments = args.first || 20
          fields = nil # hash of embedded collections

          case arguments
          when Integer
            crit.options[:limit] = arguments
            fields = args[1] if args.size > 1
          when Hash
            fields = arguments
          end

          if fields
            crit.options[:fields] ||= {}
            crit.options[:fields][:limit] = fields
          end
        end
      end

    end
  end

  module Contexts #:nodoc:
    class Mongo

      # Filters the field list. If no fields have been supplied, then it will be
      # empty. If fields have been defined then _type will be included as well.
      def process_options
        fields = options[:fields]
        only = fields.delete(:only) if fields
        limits = fields.delete(:limit) if fields

        # only ?
        if only && only.size > 0
          only << :_type if !only.include?(:_type)
          only.each do |field|
            options[:fields].merge!(field => 1)
          end
        end

        # limit for embedded collections ?
        if limits && limits.size > 0
          limits.each do |field, limit|
            next if limit.blank?
            options[:fields][field] = { '$slice' => limit }
          end
        end

        options.dup
      end

    end
  end


  # without callback feature
  module Callbacks

    module ClassMethods

      def without_callback(*args, &block)
        skip_callback(*args)
        yield
        set_callback(*args)
      end

    end

  end
end