module Locomotive
  module Concerns
    module Site
      module UrlRedirections

        extend ActiveSupport::Concern

        included do

          ## fields ##
          field :url_redirections, type: Array, default: []
          field :url_redirections_information, type: Hash, default: {}

          ## virtual attributes ##
          attr_accessor :url_redirections_expert_mode

        end

        module ClassMethods

          def inc_url_redirection_counter(site_id, url)
            url_id = Digest::MD5.hexdigest(url)
            self.where(_id: site_id).inc("url_redirections_information.#{url_id}.counter" => 1)
          end

        end

        def url_redirections_plain_text
          url_redirections
          .sort { |a, b| a.first <=> b.first }
          .map { |redirection| redirection.join(' ') }
          .join("\n")
        end

        def url_redirections_with_information(with_hidden = true)
          url_redirections.map do |(source, target)|
            url_id = Digest::MD5.hexdigest(source)
            information = url_redirections_information[url_id] || {}

            if !with_hidden && information['hidden']
              nil
            else
              { 'source' => source, 'target' => target }.merge(information)
            end
          end
        end

        def add_or_update_url_redirection(source, target, information = nil)
          return false if source.blank? || target.blank?

          source, target = add_leading_slash_to(source), add_leading_slash_to(target)
          url_id = Digest::MD5.hexdigest(source)

          if redirection = url_redirections.detect { |(_source, _)| _source == source }
            redirection[1] = target
          else
            url_redirections << [source, target]
          end

          url_redirections_information[url_id] = information
        end

        def remove_url_redirection(source)
          source = add_leading_slash_to(source)
          url_id = Digest::MD5.hexdigest(source)

          url_redirections.delete_if { |(_source, _)| _source == source }
          url_redirections_information.delete(url_id)
        end

        def url_redirections=(array)
          super((array || []).flatten.map do |path|
            add_leading_slash_to(path)
          end.each_slice(2).to_a)
        end

        protected

        def add_leading_slash_to(path)
          path.starts_with?('/') || path =~ /\Ahttps+:\/\// ? path : "/#{path}"
        end

      end
    end
  end
end
