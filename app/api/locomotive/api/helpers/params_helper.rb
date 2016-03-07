module Locomotive
  module API
    module Helpers
      module ParamsHelper

        def permitted_params
          @permitted_params ||= declared(params, include_missing: false)
        end

        # Much safer than permitted_params because it also uses the current policy
        # (Pundit) to filter the parameters.
        #
        # Examples:
        #
        # permitted_params_from_policy(current_site, :site)
        #
        # If we want to deal with ActionDispatch::Http::UploadedFile instances
        # instead of hashes (which would break the permitted attributes policy).
        #
        # permitted_params_from_policy(current_site, :site, [:picture])
        #
        def permitted_params_from_policy(object_or_class, key, file_keys = nil, json_keys = nil)
          _params = permitted_params[key]

          build_uploaded_files_from_params!(_params, file_keys) if file_keys

          json_params = json_params!(_params, json_keys || [])

          _attributes = policy(object_or_class).permitted_attributes

          ::ActionController::Parameters.new(_params).permit(*_attributes).tap do |strong_params|
            (json_keys || []).each { |k| strong_params[k] = json_params[k] }
          end
        end

        def build_uploaded_files_from_params!(hash, list)
          list.each do |name|
            file_hash = hash[name]

            next unless file_hash.try(:has_key?, :tempfile)

            hash[name] = ActionDispatch::Http::UploadedFile.new(file_hash)
          end
        end

        def json_params!(hash, keys)
          {}.tap do |json_params|
            keys.each { |key| json_params[key] = hash.delete(key) }
          end
        end

      end

    end
  end
end
