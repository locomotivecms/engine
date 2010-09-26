module Locomotive
  module Import
    module Snippets

      def self.process(context)
        site, theme_path = context[:site], context[:theme_path]

        Dir[File.join(theme_path, 'snippets', '*')].each do |snippet_path|

          name = File.basename(snippet_path, File.extname(snippet_path)).parameterize('_')
          
          snippet = site.snippets.where(:slug => name).first || site.snippets.build(:name => name)

          snippet.template = File.read(snippet_path) # = site.snippets.create! :name => name, :template => 
          
          snippet.save!
          # puts "snippet = #{snippet.inspect}"
        end
      end

    end
  end
end