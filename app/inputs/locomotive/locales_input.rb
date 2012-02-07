module Locomotive
  class LocalesInput < ::Formtastic::Inputs::CheckBoxesInput

    def to_html
      input_wrapping do
        label_html <<
        choices_group_wrapping do
          collection.map { |choice|
            choice_wrapping(choice_wrapping_html_options(choice)) do
              choice_html(choice)
            end
          }.join("\n").html_safe
        end
      end
    end

    def choices_group_wrapping(&block)
      template.content_tag(:div,
        template.capture(&block),
        choices_group_wrapping_html_options
      )
    end

    def choice_wrapping(html_options, &block)
      template.content_tag(:div,
        template.capture(&block),
        html_options
      )
    end

    def choice_html(choice)
      check_box_without_hidden_input(choice) <<
      template.content_tag(:label,
        choice_label(choice),
        label_html_options.merge(:for => choice_input_dom_id(choice), :class => nil)
      )
    end

    def choice_label(choice)
      text = I18n.t("locomotive.locales.#{choice}")
      template.image_tag("locomotive/icons/flags/#{choice}.png", :alt => text) << text
    end

    def choices_group_wrapping_html_options
      { :class => 'list' }
    end

    def choice_wrapping_html_options(choice)
      super.tap do |options|
        options[:class] = "entry #{checked?(choice) ? 'selected' : ''}"
      end
    end

    def hidden_fields?
      false
    end

  end
end
