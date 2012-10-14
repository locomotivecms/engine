module Locomotive
  class AccountPresenter < BasePresenter

    delegate :name, :email, :locale, :to => :source

    def admin
      self.source.admin?
    end

    def included_methods
      super + %w(name email locale admin)
    end

  end
end