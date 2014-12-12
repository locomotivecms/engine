module Locomotive
  module Routing
    class PostContentEntryConstraint

      def matches?(request)
        request.post? && request.params[:content_type_slug].present?
      end

    end
  end
end