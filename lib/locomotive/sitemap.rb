module Locomotive
  
  class Sitemap
    
    attr_accessor :index, :children, :not_found
    
    def initialize(site)
      self.children = site.pages.roots.to_a
      
      self.index = self.children.detect { |p| p.index? }
      self.not_found = self.children.detect { |p| p.not_found? }
      
      self.children.delete(self.index)
      self.children.delete(self.not_found)     
    end
    
    def empty?
      self.index.nil? && self.not_found.nil? && self.children.empty?
    end
        
    def self.build(site); self.new(site); end
        
  end
  
  # module Sitemap
  # 
  #   def self.build(pages)
  #     return [] if pages.empty?
  #     
  #     # pages = pages.to_a.clone # make a secure copy
  #     dictionary = build_dictionary(pages)
  #     
  #     returning [] do |map|
  #       map << (index = pages.detect { |p| p.index? })
  #       pages.delete(index)
  #       
  #       not_found = pages.detect { |p| p.not_found? }
  #       pages.delete(not_found)
  #       
  #       add_children()
  #       
  #       map << not_found
  #     end
  #   end
  #   
  #   protected
  #   
  #   def self.add_children(map, children, dictionary)
  #     
  #   end
  #   
  #   def self.build_dictionary(pages)
  #     returning({}) do |hash|
  #       hash[pages.id] = pages
  #     end
  #   end
  #  
  #   # def self.build(pages)
  #   #   return Folder.new if pages.empty?      
  #   #   
  #   #   pages = pages.to_a.clone # make a secure copy                  
  #   #   
  #   #   root = Folder.new :root => pages.delete_if { |p| p.path == 'index' }
  #   #  
  #   #   pages.each do |page|
  #   #     
  #   #   end
  #   # end
  #   #    
  #   # class Folder
  #   #   attr_accessor :root, :depth, :children
  #   #  
  #   #   def initialize(attributes = {})
  #   #     self.root = attributes[:root]
  #   #     self.depth = self.root.depth
  #   #   end
  #   #  
  #   # end
  #   
  # end
  
end