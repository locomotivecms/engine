module Models
  
  module Extensions
    
    module Page
      
      module Render

        def render(context)
          self.template.render(context)

          if self.layout
            self.layout.template.render(context)
          else
            ::Liquid::Template.parse("{{ content_for_layout }}").render(context)
          end
        end
        
      end
      
    end
    
  end
  
end