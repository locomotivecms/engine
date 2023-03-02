module ActionDispatch
  class TestRequest
    # Override host, by default it is test.host
    def host
      'locomotive.local'
    end
  end
end