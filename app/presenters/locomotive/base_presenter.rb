class Locomotive::BasePresenter

  include Locomotive::Presentable

  include ActionView::Helpers::SanitizeHelper
  extend  ActionView::Helpers::SanitizeHelper::ClassMethods
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::NumberHelper

  ## default properties ##
  with_options allow_nil: true do |presenter|
    presenter.properties    :id, :_id
  end
  properties  :created_at, :updated_at, type: 'Date', only_getter: true

  ## utility accessors ##
  attr_reader :__ability, :__depth

  # Set the ability object to check if we can or not
  # get a property.
  #
  def after_initialize
    @__depth    = self.__options[:depth] || 0
    @__ability  = self.__options[:ability]

    if self.__options[:current_account] && self.__options[:current_site]
      @__ability = Locomotive::Ability.new self.__options[:current_account], self.__options[:current_site]
    end
  end

  # Get the id of the source only if it has been persisted
  # or if it's an embedded document.
  #
  # @return [ String ] The id of the source, nil if not persisted or not embedded.
  #
  def _id
    self.__source.persisted? || self.__source.embedded? ? self.__source._id.to_s : nil
  end

  alias :id :_id

  # Check if there is an ability object used for permissions.
  #
  # @return [ Boolean ] True if defined, false otherwise
  #
  def ability?
    self.__ability.present?
  end

  # Shortcut to the site taken from the source.
  #
  # @return [ Object ] The site or nil if not found
  #
  def site
    self.__source.try(:site)
  end

  # Shortcut to the errors of the source
  #
  # @return [ Hash ] The errors or an empty hash if no errors
  #
  def errors
    self.__source.errors.messages.to_hash.stringify_keys
  end

  # Tell if we have to include errors or not
  #
  # @return [ Boolean ] True if the source has errors.
  #
  def include_errors?
    !!self.__options[:include_errors]
  end

  # Tell if the presenter is aimed to be used in a html view
  #
  # @return [ Boolean ] True if used in a HTML view
  #
  def html_view?
    !!self.__options[:html_view]
  end

  # Mimic format used by to_json
  #
  # @param [ String ] text The string representing the time
  #
  # @return [ Time ] The time or nil if the input is nil or empty
  #
  def formatted_time(text)
    return nil if text.blank?
    format = '%Y-%m-%dT%H:%M:%S%Z'
    ::Time.strptime(text, format)
  end

  # Return the set of setters with their options.
  #
  # @param [ Hash ] options Some options: with_ids (add id and _id)
  #
  # @return [ Hash ] The setters
  #
  def self.setters_to_hash(options = {})
    options = { without_ids: true }.merge(options)

    {}.tap do |hash|
      self.setters.each do |name|
        next if %w(id _id).include?(name.to_s) && options[:without_ids]
        hash[name] = self.getters_or_setters_to_hash(name)
      end
    end
  end

  # Return the set of getters with their options.
  #
  # @return [ Hash ] The getters
  #
  def self.getters_to_hash
    {}.tap do |hash|
      self.getters.each do |name|
        next if %w(_id screated_at updated_at).include?(name)
        hash[name] = self.getters_or_setters_to_hash(name)
      end

      %w(created_at updated_at).each do |name|
        hash[name] = self.getters_or_setters_to_hash(name)
      end
    end
  end

  def self.getters_or_setters_to_hash(name)
    options   = self.property_options[name] || {}

    attributes = {
      type:         options[:type] || 'String',
      required:     options[:required].nil? ? true : options[:required],
      alias_of:     self.alias_of(name),
      description:  options[:description]
    }

    if options[:presenter]
      attributes[:collection_of] = {
        name:   options[:presenter].to_s.demodulize.gsub(/Presenter$/, '').underscore,
        params: options[:presenter].setters_to_hash
      }
    end

    attributes
  end

end
