class Locomotive::BasePresenter

  include ActionView::Helpers::SanitizeHelper
  extend ActionView::Helpers::SanitizeHelper::ClassMethods
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::NumberHelper

  attr_reader :source

  def initialize(object)
    @source = object
  end

  def id
    @source._id.to_s
  end

  # def as_json(options = {})
  #   @source.as_json(options)
  # end

end