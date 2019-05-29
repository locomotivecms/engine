module Locomotive
  module Steam
    module Middlewares

      class PageEditing

        include Locomotive::Engine.routes.url_helpers

        def initialize(app, opts = {})
          @app = app
        end

        def call(env)
          disable_live_editing_if_not_html(env)

          status, headers, response = @app.call(env)

          site, mounted_on, page, locale, live_editing = env['steam.site'], env['steam.mounted_on'], env['steam.page'], env['steam.locale'].to_s, env['steam.live_editing']

          if editable?(page, response, live_editing)
            html = %(
              <meta name="locomotive-locale" content="#{locale}" />
              <meta name="locomotive-editable-elements-path" content="#{editable_elements_path(site, page, locale, env)}" />
              <meta name="locomotive-page-id" content="#{page._id}" />
              <meta name="locomotive-content-entry-id" content="#{content_entry_id(env)}" />
              <meta name="locomotive-mounted-on" content="#{mounted_on}" />

              <link href='https://fonts.googleapis.com/css?family=Noto+Sans' rel='stylesheet' type='text/css'>

              <!-- [Locomotive] fix absolute links to inner pages in preview mode-->
              <script type="text/javascript">
                window.document.addEventListener('click', function(event) {
                  var qs = document.querySelectorAll('a');
                  if (qs) {
                    var el = event.target, index = -1;
                    while (el && ((index = Array.prototype.indexOf.call(qs, el)) === -1)) {
                      el = el.parentElement;
                    }
                    if (index > -1) {
                      var url = el.getAttribute('href');
                      if (url && url[0] == '/' && url.indexOf('#{mounted_on}') == -1 && url.indexOf('/sites/') == -1) {
                        el.setAttribute('href', '#{mounted_on}' + url);
                      }
                    }
                  }
                });
              </script>
            )
            response.first.gsub!('</head>', %(#{html}</head>))

            # make sure there is no span tags within the head.
            # For the record, Steam adds a span tag next to a block liquid tag
            response.first.gsub!(/<head>(.+)<\/head>/m) do
              head = Regexp.last_match[1]
              "<head>#{head.gsub(/<span/, '<meta').gsub(/<\/span>/, '</meta>')}</head>"
            end

            # new way of letting the parent window know about the status of the preview
            response.first.gsub!('</body>', %(
                <script type="text/javascript">
                  if (window.parent) {
                    console.log(window.parent);
                    var event = new CustomEvent('LocomotivePreviewReady', {
                      detail: {
                        locale: "#{locale}",
                        pageId: "#{page._id}",
                        contentEntryId: "#{content_entry_id(env)}",
                        mountedOn: "#{mounted_on}"
                      }
                    });
                    window.parent.document.dispatchEvent(event);
                  }
                </script>
              </body>
            ))
          end

          [status, headers, response]
        end

        protected

        def disable_live_editing_if_not_html(env)
          page = env['steam.page']

          if page && page.response_type != 'text/html'
            env['steam.live_editing'] = false
          end
        end

        def editable?(page, response, live_editing)
          live_editing && page && !page.redirect && page.response_type == 'text/html' && response.first
        end

        def editable_elements_path(site, page, locale, env)
          options = {}

          if content_entry_id = content_entry_id(env)
            options = {
              content_entry_id: content_entry_id,
              preview_path:     env['steam.path'],
            }
          end

          options[:content_locale] = locale if site.locales.size > 1

          super(site.handle, page._id, options)
        end

        def content_entry_id(env)
          env['steam.content_entry']&._id
        end

      end

    end
  end
end
