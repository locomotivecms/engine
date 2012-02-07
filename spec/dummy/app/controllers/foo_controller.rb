class FooController < Locomotive::BaseController

  skip_load_and_authorize_resource

  sections :foo

  def index
  end

end