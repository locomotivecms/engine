module Locomotive
  module Import
    class Snippets < Base

      def process
        Dir[File.join(theme_path, 'app', 'views', 'snippets', '*')].each do |snippet_path|
          self.log "path = #{snippet_path}"

          name = File.basename(snippet_path, File.extname(snippet_path)).parameterize('_')

          snippet = site.snippets.where(:slug => name).first || site.snippets.build(:name => name)

          snippet.template = File.read(snippet_path)

          snippet.save!
        end
      end

    end
  end
end