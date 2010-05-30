module Locomotive
  
  module Liquid
  
    # Works only with snippets 
    class DbFileSystem
        
      def read_template_file(site, template_path)
        raise FileSystemError, "Illegal snippet name '#{template_path}'" unless template_path =~ /^[^.\/][a-zA-Z0-9_\/]+$/
    
        snippet = site.snippets.where(:slug => template_path).first
        
        raise FileSystemError, "No such snippet '#{template_path}'" if snippet.nil?
      
        snippet.template
      end
        
    end
  
  end
  
end