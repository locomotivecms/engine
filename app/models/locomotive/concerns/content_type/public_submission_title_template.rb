module Locomotive
  module Concerns
    module ContentType
      module PublicSubmissionTitleTemplate

        extend ActiveSupport::Concern

        included do
          field :public_submission_title_template
        end

        def public_submission_title(entry, options)
          template = ::Liquid::Template.parse(self.public_submission_title_template, {})

          assigns   = { 'site' => self.site, 'entry' => entry }.merge(options)
          registers = { site: self.site }

          template.render(::Liquid::Context.new({}, assigns, registers))
        end

      end
    end
  end
end
