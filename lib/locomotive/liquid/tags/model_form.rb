module Locomotive
  module Liquid
    module Tags

      # Display the form html tag with the appropriate hidden fields in order to create
      # a content entry from a public site.
      # It handles callbacks, csrf and target url out of the box.
      #
      # Usage:
      #
      # {% model_form 'newsletter_addresses' %}
      #    <input type='text' name='content[email]' />
      #     <input type='submit' value='Add' />
      # {% endform_form %}
      #
      # {% model_form 'newsletter_addresses', class: 'a-css-class', success: 'http://www.google.fr', error: '/error' %}...{% endform_form %}
      #
      class ModelForm < Solid::Block

        tag_name :model_form

        def display(*options, &block)
          name    = options.shift
          options = options.shift || {}

          form_attributes = { method: 'POST', enctype: 'multipart/form-data' }.merge(options.slice(:id, :class))

          html_content_tag :form,
            content_type_html(name) + csrf_html + callbacks_html(options) + yield,
            form_attributes
        end

        def content_type_html(name)
          html_tag :input, type: 'hidden', name: 'content_type_slug', value: name
        end

        def csrf_html
          name  = controller.send(:request_forgery_protection_token).to_s
          value = controller.send(:form_authenticity_token)

          html_tag :input, type: 'hidden', name: name, value: value
        end

        def callbacks_html(options)
          options.slice(:success, :error).map do |(name, value)|
            html_tag :input, type: 'hidden', name: "#{name}_callback", value: value
          end.join('')
        end

        private

        def controller
          current_context.registers[:controller]
        end

        def html_content_tag(name, content, options = {})
          "<#{name} #{inline_options(options)}>#{content}</#{name}>"
        end

        def html_tag(name, options = {})
          "<#{name} #{inline_options(options)} />"
        end

        # Write options (Hash) into a string according to the following pattern:
        # <key1>="<value1>", <key2>="<value2", ...etc
        def inline_options(options = {})
          return '' if options.empty?
          (options.stringify_keys.to_a.collect { |a, b| "#{a}=\"#{b}\"" }).join(' ')
        end

      end

    end
  end
end