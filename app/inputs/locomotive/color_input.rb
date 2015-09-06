module Locomotive
  class ColorInput < ::SimpleForm::Inputs::StringInput

    def input(wrapper_options)
      <<-HTML
        <div class="input-group">
          #{super}
          <span class="input-group-addon"><i></i></span>
        </div>
      HTML
    end

    def html5?
      false
    end

  end
end
