module HTTPHelpers

  attr_accessor :default_params

  def add_default_params(params)
    default_params.merge!(params)
  end

  def do_request(type, base_url, url, params)
    request_method = type.downcase.to_sym
    send(request_method, URI.join(base_url, url).to_s, default_params.merge(params))
  end

  protected

  def default_params
    @default_params ||= {}
  end

end

World(HTTPHelpers)
