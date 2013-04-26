module Locomotive
  module Liquid
    module Drops

      class SessionProxy < ::Liquid::Drop

        def before_method(meth)
          controller = @context.registers[:controller]
          controller.session[meth.to_sym]
        end

      end

    end
  end
end