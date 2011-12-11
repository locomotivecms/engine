module Locomotive
  module Import
    class Model

      include Logger
      include ActiveModel::Validations

      ## fields ##
      attr_accessor :site, :source, :reset, :samples, :enabled

      ## validation ##
      validates :site, :source, :presence => true

      def initialize(attributes = {})
        attributes = HashWithIndifferentAccess.new(attributes)
        self.site     = attributes[:site]
        self.source   = attributes[:source]
        self.reset    = attributes[:reset] || false
        self.samples  = attributes[:samples] || false
        self.enabled  = attributes[:enabled] || {}
      end

      def reset=(value)
        @reset = Boolean.set(value)
      end

      def samples=(value)
        @samples = Boolean.set(value)
      end

      ## methods ##

      def to_job
        new Job()
      end

      def to_key
        ['import']
      end

      ## class methods ##

      def self.create(attributes = {})
        new(attributes).tap do |job|
          if job.valid?
            begin
              self.launch!(job)
            rescue Exception => e
              job.log "#{e.message}\n#{e.backtrace}"
              job.errors.add(:source, e.message)
            end
          end
        end
      end

      def self.launch!(job)
        Locomotive::Import::Job.run! job.source, job.site, {
          :reset    => job.reset,
          :enabled  => job.enabled
        }
      end

      def self.current(site)
        job = Delayed::Job.where({ :job_type => 'import', :site_id => site.id }).last

        {
          :step   => job.nil? ? 'done' : job.step,
          :failed => job && job.last_error.present?
        }
      end

      def self.name
        'Import'
      end

    end
  end
end