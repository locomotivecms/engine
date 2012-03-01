class Locomotive::BasePresenter

  include ActionView::Helpers::SanitizeHelper
  extend  ActionView::Helpers::SanitizeHelper::ClassMethods
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::NumberHelper

  attr_reader :source, :options, :ability, :depth

  delegate :created_at, :updated_at, :to => :source

  def initialize(object, options = {})
    @source   = object
    @options  = options || {}
    @depth    = options[:depth] || 0
    @ability  = options[:ability]

    if @options[:current_account] && @options[:current_site]
      @ability = Locomotive::Ability.new @options[:current_account], @options[:current_site]
    end
  end

  def id
    self.source.persisted? || self.source.embedded? ? self.source._id.to_s : nil
  end

  alias :_id :id

  def ability?
    self.ability.present?
  end

  def included_methods
    %w(id _id created_at updated_at)
  end

  def as_json(methods = nil)
    methods ||= self.included_methods
    {}.tap do |hash|
      methods.each do |meth|
        hash[meth] = self.send(meth.to_sym) rescue nil
      end
    end
  end

end