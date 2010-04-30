module Locomotive
  
  module SiteMap
   
    def self.build(pages)
      return Folder.new if pages.empty?      
      
      pages = pages.to_a.clone # make a secure copy                  
      
      root = Folder.new :root => pages.delete_if { |p| p.path == 'index' }
     
      pages.each do |page|
        
      end
    end
   
    class Folder
      attr_accessor :root, :name, :children
     
      def initialize(attributes = {})
        self.root = attributes[:root]
        self.name = attributes[:name]
      end
     
    end
    
  end
  
end