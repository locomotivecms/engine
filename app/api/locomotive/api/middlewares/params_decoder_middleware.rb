# Issue here: https://github.com/ruby-grape/grape/issues/1028
# Solution: https://github.com/typhoeus/typhoeus/blob/master/lib/rack/typhoeus/middleware/params_decoder/helper.rb
#
# MIT License Paul Dix, David Balatero, Hans Hasselberg
#
module Locomotive
  module API
    module Middlewares

      class ParamsDecoderMiddleware

        def initialize(app)
          @app = app
        end

        def call(env)
          request = Rack::Request.new(env)
          decode(request.params).each_pair { |k, v| update_params request, k, v }
          @app.call(env)
        end

        private

        # Persist params change in environment. Extracted from:
        # https://github.com/rack/rack/blob/master/lib/rack/request.rb#L243
        def update_params(req, k, v)
          found = false
          if req.GET.has_key?(k)
            found = true
            req.GET[k] = v
          end
          if req.POST.has_key?(k)
            found = true
            req.POST[k] = v
          end
          unless found
            req.GET[k] = v
          end
        end

        def decode!(hash)
          return hash unless hash.is_a?(Hash)
          hash.each_pair do |key,value|
            if value.is_a?(Hash)
              decode!(value)
              hash[key] = convert(value)
            end
          end
          hash
        end

        def decode(hash)
          decode!(hash.dup)
        end

        # Checks if Hash is an Array encoded as a Hash.
        # Specifically will check for the Hash to have this
        # form: {'0' => v0, '1' => v1, .., 'n' => vN }
        #
        # @param hash [Hash]
        #
        # @return [Boolean] True if its a encoded Array, else false.
        def encoded?(hash)
          return false if hash.empty?
          if hash.keys.size > 1
            keys = hash.keys.map{|i| i.to_i if i.respond_to?(:to_i)}.sort
            keys == hash.keys.size.times.to_a
          else
            hash.keys.first =~ /0/
          end
        end

        # If the Hash is an array encoded by typhoeus an array is returned
        # else the self is returned
        #
        # @param hash [Hash] The Hash to convert into an Array.
        #
        # @return [Arraya/Hash]
        def convert(hash)
          if encoded?(hash)
            hash.sort{ |a, b| a[0].to_i <=> b[0].to_i }.map{ |key, value| value }
          else
            hash
          end
        end

      end

    end
  end
end
