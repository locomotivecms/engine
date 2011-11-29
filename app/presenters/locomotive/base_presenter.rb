class Locomotive::BasePresenter

  include ActionView::Helpers::SanitizeHelper
  extend ActionView::Helpers::SanitizeHelper::ClassMethods
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::NumberHelper

  attr_reader :source, :options, :ability

  delegate :created_at, :updated_at, :to => :source

  def initialize(object, options = {})
    @source   = object
    @options  = options

    if @options && @options[:current_account] && @options[:current_site]
      @ability = Locomotive::Ability.new @options[:current_account], @options[:current_site]
    end
  end

  def id
    @source._id.to_s
  end

  def ability?
    self.ability.present?
  end

  def included_methods
    %w(id created_at updated_at)
  end

  def as_json
    {}.tap do |hash|
      self.included_methods.map(&:to_sym).each do |meth|
        hash[meth] = self.send(meth) rescue nil
      end
    end
  end

end