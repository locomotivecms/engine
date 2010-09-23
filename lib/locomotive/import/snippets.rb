module Locomotive
  module Import
    module Snippets

      def self.process(context)
        site, theme_path = context[:site], context[:theme_path]

        Dir[File.join(theme_path, 'snippets', '*')].each do |snippet_path|

          name = File.basename(snippet_path, File.extname(snippet_path)).parameterize('_')

          snippet = site.snippets.create! :name => name, :template => File.read(snippet_path)

          # puts "snippet = #{snippet.inspect}"
        end
      end

    end
  end
end