module Locomotive
  module PublicSubmissionAccountsHelper

    def options_for_public_submission_accounts
      current_site.accounts.collect { |a| [CGI::escapeHTML("#{a.name} <#{a.email}>"), a.id.to_s] }
    end

  end
end


