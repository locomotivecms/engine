module Locomotive
  class RteInput < FormtasticBootstrap::Inputs::TextInput

    def to_html
      bootstrap_wrapping do
        toolbar_html +
        builder.text_area(method, form_control_input_html_options)
      end
    end

    def toolbar_html
      %{
      <div id="wysihtml5-toolbar" class="wysihtml5-toolbar" style="display: none;">
        <span class="wysihtml5-toolbar-group">
          <a data-wysihtml5-command="bold"><i class="fa fa-bold"></i></a>
          <a data-wysihtml5-command="italic"><i class="fa fa-italic"></i></a>
          <a data-wysihtml5-command="underline"><i class="fa fa-underline"></i></a>
          <a data-wysihtml5-command="strike"><i class="fa fa-strikethrough"></i></a>
        </span>

        <span class="wysihtml5-toolbar-group">
          <a data-wysihtml5-command="justifyLeft"><i class="fa fa-align-left"></i></a>
          <a data-wysihtml5-command="justifyCenter"><i class="fa fa-align-center"></i></a>
          <a data-wysihtml5-command="justifyRight"><i class="fa fa-align-right"></i></a>
          <a data-wysihtml5-command="justifyFull"><i class="fa fa-align-justify"></i></a>
        </span>

        <span class="wysihtml5-toolbar-group">
          <a data-wysihtml5-command="insertUnorderedList"><i class="fa fa-list-ul"></i></a>
          <a data-wysihtml5-command="insertOrderedList"><i class="fa fa-list-ol"></i></a>
          <a class="style"><i class="fa fa-paragraph"></i></a>
          <div class="style-dialog-content" style="display: none">
            <a data-wysihtml5-command="formatBlock" data-wysihtml5-command-value="h1">H1</a><br>
            <a data-wysihtml5-command="formatBlock" data-wysihtml5-command-value="h2">H2</a><br>
            <a data-wysihtml5-command="formatBlock" data-wysihtml5-command-value="h3">H3</a><br>
            <a data-wysihtml5-command="formatBlock" data-wysihtml5-command-value="h3">H4</a><br>
            <a data-wysihtml5-command="formatBlock" data-wysihtml5-command-value="h3">H5</a><br>
            <a data-wysihtml5-command="formatBlock" data-wysihtml5-command-value="h3">H6</a><br>
            <a data-wysihtml5-command="formatBlock" data-wysihtml5-command-value="p">P</a><br>
            <a data-wysihtml5-command="formatBlock" data-wysihtml5-command-value="blockquote"><i class="fa fa-quote-right"></i></a><br>
          </div>
          <a data-wysihtml5-command="createLink"><i class="fa fa-chain"></i></a>
          <div class="link-dialog-content" style="display: none">
            <div class="form-group">
              <label for="wysihtml5-link-url">Link URL</label>
              <input type="text" name="url" class="form-control" id="wysihtml5-link-url">
            </div>
            <div class="form-group">
              <label for="wysihtml5-link-target">Target</label>
              <select name="target" id="wysihtml5-link-target" class="form-control">
                <option value>-- Not Set--</option>
                <option value="_self">Open Link in the Same window</option>
                <option value="_blank">Open Link in a New Window</option>
              </select>
            </div>
            <div class="form-group">
              <label for="wysihtml5-link-title">Title</label>
              <input type="text" name="title" class="form-control" id="wysihtml5-link-title">
            </div>
            <p class="text-right">
              <a class="btn btn-primary btn-sm apply">Ok</a>
              &nbsp;
              <a class="btn btn-default btn-sm cancel">Cancel</a>
            </p>
          </div>
          <a data-wysihtml5-command="removeLink"><i class="fa fa-chain-broken"></i></a>
        </span>


        <span class="wysihtml5-toolbar-group">
          <a data-wysihtml5-action="change_view"><i class="fa fa-code"></i></a>
        </span>

        <!-- Some wysihtml5 commands require extra parameters -->
        <!--
        <a data-wysihtml5-command="foreColor" data-wysihtml5-command-value="red">red</a>
        <a data-wysihtml5-command="foreColor" data-wysihtml5-command-value="green">green</a>
        <a data-wysihtml5-command="foreColor" data-wysihtml5-command-value="blue">blue</a>
        -->
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