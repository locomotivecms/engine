module Locomotive
  module Extensions
    module Page
      module Render

        extend ActiveSupport::Concern

        def render(context)
          self.template.render(context)
        end

        module ClassMethods

          # Given both a site and a path, this method tries
          # to get the matching page.
          # If the page is templatized, the related content entry is
          # associated to the page (page.content_entry stores the entry).
          # If no page is found, then it returns the 404 one instead.
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
                if _page.templatized?
                  %r(^#{_page.fullpath.gsub('content_type_template', '([^\/]+)')}$) =~ path

                  permalink = $1

                  _page.content_entry = _page.fetch_target_entry(permalink)

                  if _page.content_entry.nil? || (!_page.content_entry.visible? && !logged_in) # content instance not found or not visible
                    next
                  end
                end
              end

              page = _page

              break
            end

            page || site.pages.not_found.published.first
          end

          # Calculate all the combinations possible based on the
          # fact that one of the segment of the path could be
          # a content type from a templatized page.
          # We postulate that there is only one templatized page in a path
          # (ie: no nested templatized pages)
          #
          # @param [ String ] path The path to the page
          #
          # @return [ Array ] An array of all the combinations
          #
          def path_combinations(path)
            _path_combinations(path.split('/'))
          end

          #:nodoc:
          def _path_combinations(segments, can_include_template = true)
            return nil if segments.empty?

            segment = segments.shift

            (can_include_template ? [segment, 'content_type_template'] : [segment]).map do |_segment|
              if (_combinations = _path_combinations(segments.clone, can_include_template && _segment != 'content_type_template'))
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