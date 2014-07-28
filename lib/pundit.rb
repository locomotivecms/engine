require "active_support/concern"

module Pundit
  class NotAuthorizedError < StandardError
    attr_accessor :query, :record, :policy
  end
  class AuthorizationNotPerformedError < StandardError; end
  class NotDefinedError < StandardError; end
  #
  extend ActiveSupport::Concern

  class << self
    def policy(user, site, resource)
      Locomotive::ApplicationPolicy.new(user, site, resource)
    end
    alias_method :policy!, :policy
  end

  included do
    if respond_to?(:helper_method)
      helper_method :policy
      helper_method :pundit_user
    end
    if respond_to?(:hide_action)
      hide_action :authorize
      hide_action :pundit_user
    end
  end

  def authorize(record, query=nil)
    query ||= params[:action].to_s + "?"
    @_policy_authorized = true

    policy = policy(record)
    unless policy.public_send(query)
      error = NotAuthorizedError.new("not allowed to #{query} this #{record}")
      error.query, error.record, error.policy = query, record, policy

      raise error
    end

    true
  end

  def policy(resource)
    @policy or Pundit.policy!(pundit_user, pundit_site, resource)
  end
  attr_writer :policy

  def pundit_site
    current_site
  end

  def pundit_user
    current_locomotive_account
  end
end
