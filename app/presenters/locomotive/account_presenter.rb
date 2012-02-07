module Locomotive
  class AccountPresenter < BasePresenter

    delegate :name, :email, :locale, :to => :source

    def included_methods
      super + %w(name email locale)
    end

  end
end