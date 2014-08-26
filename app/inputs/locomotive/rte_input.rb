module Locomotive
  class RteInput < FormtasticBootstrap::Inputs::TextInput

    def to_html
      bootstrap_wrapping do
        toolbar_html +
        builder.text_area(method, form_control_input_html_options)
      end
    end

    def toolbar_html
      # template.content_tag :p, 'Hello world'

      %{
      <div id="wysihtml5-toolbar" style="display: none;">
        <a data-wysihtml5-command="bold"><i class="fa fa-bold"></i></a>
        <a data-wysihtml5-command="italic"><i class="fa fa-italic"></i></a>
        <a data-wysihtml5-command="underline"><i class="fa fa-underline"></i></a>
        <a data-wysihtml5-command="strike"><i class="fa fa-strikethrough"></i></a>

        &nbsp;

        <a data-wysihtml5-command="justifyLeft"><i class="fa fa-align-left"></i></a>
        <a data-wysihtml5-command="justifyCenter"><i class="fa fa-align-center"></i></a>
        <a data-wysihtml5-command="justifyRight"><i class="fa fa-align-right"></i></a>
        <a data-wysihtml5-command="justifyFull"><i class="fa fa-align-justify"></i></a>

        &nbsp;

        <a data-wysihtml5-action="change_view"><i class="fa fa-code"></i></a>

        &nbsp;


        <!-- Some wysihtml5 commands require extra parameters -->
        <a data-wysihtml5-command="foreColor" data-wysihtml5-command-value="red">red</a>
        <a data-wysihtml5-command="foreColor" data-wysihtml5-command-value="green">green</a>
        <a data-wysihtml5-command="foreColor" data-wysihtml5-command-value="blue">blue</a>

        <!-- Some wysihtml5 commands like 'createLink' require extra paramaters specified by the user (eg. href) -->
        <a data-wysihtml5-command="createLink">insert link</a>
        <div data-wysihtml5-dialog="createLink" style="display: none;">
          <label>
            Link:
            <input data-wysihtml5-dialog-field="href" value="http://" class="text">
          </label>
          <a data-wysihtml5-dialog-action="save">OK</a> <a data-wysihtml5-dialog-action="cancel">Cancel</a>
        </div>
      </div>
      }.html_safe
    end

    # def bootstrap_wrapping(&block)
    #   form_group_wrapping do
    #     label_html <<
    #     hint_html(:inline) <<
    #     error_html(:inline) <<
    #     toolbar_html <<
    #     template.content_tag(:span, :class => 'form-wrapper') do
    #       input_content(&block)
    #     end
    #   end
    # end

    # def form_wrapper_html(&block)
    #   toolbar_html +
    #   template.content_tag(:span, class: 'form-wrapper') do
    #     input_content(&block)
    #   end
    # end

    #< Formtastic::Inputs::TextInput

    # def to_html
    #   input_wrapping do
    #     label_html <<
    #     builder.text_area(method, input_html_options) <<
    #     template.content_tag(:span, '', class: 'error-anchor')
    #   end
    # end

  end
end