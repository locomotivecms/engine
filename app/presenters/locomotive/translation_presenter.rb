module Locomotive
  class TranslationPresenter < BasePresenter

    delegate :key, :values, :to => :source

    def included_methods
      super + %w(key values)
    end

  end
end