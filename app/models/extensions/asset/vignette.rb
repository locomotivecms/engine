module Models  
  module Extensions    
    module Asset      
      module Vignette
        
        def vignette_url
          if self.image?
            if self.width < 80 && self.height < 80
              self.source.url
            else
              self.source.url(:medium)
            end
          # elsif asset.pdf?
          #   image_tag(asset.source.url(:medium))
          else
            mime_type_to_url(:medium)
          end
        end
        
        protected
        
        def mime_type_to_url(size)
          mime_type = File.mime_type?(self.source_filename)
          filename = "unknown"

          if !(mime_type =~ /pdf/).nil?
            filename = "PDF"
          elsif !(mime_type =~ /css/).nil?
            filename = "CSS"
          elsif !(mime_type =~ /javascript/).nil?
            filename = "JAVA"
          elsif !(mime_type =~ /font/).nil?
            filename = "FON"
          end

          File.join("admin", "icons", "filetype", size.to_s, filename + ".png")
        end
        
      end      
    end    
  end  
end