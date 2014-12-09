  def env_for(url, opts={})
    Rack::MockRequest.env_for(url, opts)
  end
