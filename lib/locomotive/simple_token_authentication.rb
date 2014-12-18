# Fix bug: https://github.com/gonzalo-bulnes/simple_token_authentication/issues/83
module SimpleTokenAuthentication
  class Entity
    def name
      @name.gsub('::', '-')
    end
    def name_underscore
      name.underscore.gsub('-', '_')
    end
  end
end
