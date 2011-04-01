module Extensions
  module Page
    module Render

      def render(context)
        self.template.render(context)
      end

    end
  end
end