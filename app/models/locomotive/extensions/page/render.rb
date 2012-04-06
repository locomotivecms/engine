module Locomotive
  module Extensions
    module Page
      module Render

        extend ActiveSupport::Concern

        def render(context)
          self.template.render(context)
        end

        module ClassMethods

          # Given both a site and a path, this method retrieves
          # the matching page if it exists.
          # If the found page owns wildcards in its fullpath, then
          # assigns the value for each wildcard and store the result within the page.
          #
          # @param [ Site ] site The site where to find the page
          # @param [ String ] path The fullpath got from the request
          # @param [ Boolean ] logged_in True if someone is logged in Locomotive
          #
          # @return [ Page ] The page matching the criteria OR the 404 one if none
          #
          def fetch_page_from_path(site, path, logged_in)
            page  = nil
            depth = path == 'index' ? 0 : path.split('/').size

            matching_paths = path == 'index' ? %w(index) : path_combinations(path)

            site.pages.where(:depth => depth, :fullpath.in => matching_paths).each do |_page|
              if !_page.published? && !logged_in
                next
              else
                _page.match_wildcards(path)
              end

              page = _page

              break
            end

            page || site.pages.not_found.published.first
          end

          # Calculate all the combinations possible based on the
          # fact that one of the segment of the path could be
          # a wildcard.
          #
          # @param [ String ] path The path to the page
          #
          # @return [ Array ] An array of all the combinations
          #
          def path_combinations(path)
            _path_combinations(path.split('/'))
          end

          #:nodoc:
          def _path_combinations(segments)
            return nil if segments.empty?

            segment = segments.shift

            [segment, '*'].map do |_segment|
              if (_combinations = _path_combinations(segments.clone))
                [*_combinations].map do |_combination|
                  File.join(_segment, _combination)
                end
              else
                [_segment]
              end
            end.flatten
          end

        end

      end
    end
  end
end