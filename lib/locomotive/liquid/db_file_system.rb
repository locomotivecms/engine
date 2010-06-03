module Locomotive  
  module Liquid      
    class DbFileSystem     
         
      # Works only with snippets 
      def read_template_file(site, template_path)
        raise FileSystemError, "Illegal snippet name '#{template_path}'" unless template_path =~ /^[^.\/][a-zA-Z0-9_\/]+$/
    
        snippet = site.snippets.where(:slug => template_path).first
        
        raise FileSystemError, "No such snippet '#{template_path}'" if snippet.nil?
      
        snippet.template
      end          
          
    end  
  end  
end