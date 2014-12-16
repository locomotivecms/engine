module Locomotive
  class RteInput < SimpleForm::Inputs::Base

    def input(wrapper_options)
      'TODO'
    end

  end
end

#     < FormtasticBootstrap::Inputs::TextInput

#     def to_html
#       bootstrap_wrapping do
#         toolbar_html +
#         builder.text_area(method, form_control_input_html_options)
#       end
#     end

#     def wysihtml5_prefix
#       dom_id.to_s
#     end

#     def link_text(name)
#       I18n.t(name, scope: 'locomotive.inputs.rte.link')
#     end

#     def toolbar_html
#       %{
#       <div id="wysihtml5-toolbar-#{wysihtml5_prefix}" class="wysihtml5-toolbar" style="display: none;">
#         <span class="wysihtml5-toolbar-group">
#           <a data-wysihtml5-command="bold"><i class="fa fa-bold"></i></a>
#           <a data-wysihtml5-command="italic"><i class="fa fa-italic"></i></a>
#           <a data-wysihtml5-command="underline"><i class="fa fa-underline"></i></a>
#           <a data-wysihtml5-command="strike"><i class="fa fa-strikethrough"></i></a>
#         </span>

#         <span class="wysihtml5-toolbar-group">
#           <a data-wysihtml5-command="justifyLeft"><i class="fa fa-align-left"></i></a>
#           <a data-wysihtml5-command="justifyCenter"><i class="fa fa-align-center"></i></a>
#           <a data-wysihtml5-command="justifyRight"><i class="fa fa-align-right"></i></a>
#           <a data-wysihtml5-command="justifyFull"><i class="fa fa-align-justify"></i></a>
#         </span>

#         <span class="wysihtml5-toolbar-group">
#           <a data-wysihtml5-command="insertUnorderedList"><i class="fa fa-list-ul"></i></a>
#           <a data-wysihtml5-command="insertOrderedList"><i class="fa fa-list-ol"></i></a>
#           <a class="style"><i class="fa fa-paragraph"></i></a>
#           <div class="style-dialog-content" style="display: none">
#             <a data-wysihtml5-command="formatBlock" data-wysihtml5-command-value="h1">H1</a><br>
#             <a data-wysihtml5-command="formatBlock" data-wysihtml5-command-value="h2">H2</a><br>
#             <a data-wysihtml5-command="formatBlock" data-wysihtml5-command-value="h3">H3</a><br>
#             <a data-wysihtml5-command="formatBlock" data-wysihtml5-command-value="h3">H4</a><br>
#             <a data-wysihtml5-command="formatBlock" data-wysihtml5-command-value="h3">H5</a><br>
#             <a data-wysihtml5-command="formatBlock" data-wysihtml5-command-value="h3">H6</a><br>
#             <a data-wysihtml5-command="formatBlock" data-wysihtml5-command-value="p">P</a><br>
#             <a data-wysihtml5-command="formatBlock" data-wysihtml5-command-value="blockquote"><i class="fa fa-quote-right"></i></a><br>
#           </div>
#           <a data-wysihtml5-command="createLink"><i class="fa fa-chain"></i></a>
#           <div class="link-dialog-content" style="display: none">
#             <div class="form-group">
#               <label for="wysihtml5-#{wysihtml5_prefix}-link-url">#{link_text(:url)}</label>
#               <input type="text" name="url" class="form-control" id="wysihtml5-#{wysihtml5_prefix}-link-url">
#             </div>
#             <div class="form-group">
#               <label for="wysihtml5-#{wysihtml5_prefix}-link-target">#{link_text(:target)}</label>
#               <select name="target" id="wysihtml5-#{wysihtml5_prefix}-link-target" class="form-control">
#                 <option value>#{link_text('target_options.not_set')}</option>
#                 <option value="_self">#{link_text('target_options.self')}</option>
#                 <option value="_blank">#{link_text('target_options.blank')}</option>
#               </select>
#             </div>
#             <div class="form-group">
#               <label for="wysihtml5-#{wysihtml5_prefix}-link-title">#{link_text(:title)}</label>
#               <input type="text" name="title" class="form-control" id="wysihtml5-#{wysihtml5_prefix}-link-title">
#             </div>
#             <p class="text-right">
#               <a class="btn btn-primary btn-sm apply">#{link_text(:ok)}</a>
#               &nbsp;
#               <a class="btn btn-default btn-sm cancel">#{link_text(:cancel)}</a>
#             </p>
#           </div>
#           <a data-wysihtml5-command="removeLink"><i class="fa fa-chain-broken"></i></a>
#           <a data-wysihtml5-command="insertFile" data-url="#{template.content_assets_path}"><i class="fa fa-file-o"></i></a>
#         </span>

#         <span class="wysihtml5-toolbar-group">
#           <a data-wysihtml5-action="change_view"><i class="fa fa-code"></i></a>
#         </span>
#       </div>
#       }.html_safe
#     end

#   end
# end
