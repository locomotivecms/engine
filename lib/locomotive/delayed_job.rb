require 'delayed_job_mongoid'

module Delayed
  module Backend
    module Base
      module ClassMethods
        # Add a job to the queue
        def enqueue(*args)
          object = args.shift
          unless object.respond_to?(:perform)
            raise ArgumentError, 'Cannot enqueue items which do not respond to perform'
          end

          attributes = {
            :job_type => object.class.name.demodulize.underscore,
            :payload_object => object,
            :priority => Delayed::Worker.default_priority,
            :run_at => nil
          }

          if args.first.respond_to?(:[])
            attributes.merge!(args.first)
          else
            attributes.merge!({
              :priority => args.first || Delayed::Worker.default_priority,
              :run_at   => args[1]
            })
          end

          self.create(attributes)
        end
      end

      def failed?
        failed_at.present?
      end
    end

    module Mongoid
      class Job
        field :job_type
        field :step
        referenced_in :site
      end
    end
  end
end
