require 'spec_helper'

describe Locomotive::Liquid::Tags::ModelForm do

  let(:tag_class) { Locomotive::Liquid::Tags::ModelForm }

  describe '#display' do

    let(:tokens) { ['Hello world', '{% endmodel_form %}'] }
    let(:options) { '"articles"' }
    let(:assigns) { {} }
    let(:controller) { stub(request_forgery_protection_token: 'token', form_authenticity_token: '42') }
    let(:context) { Liquid::Context.new({}, assigns, { controller: controller }) }

    subject { tag_class.new('model_form', options, tokens).render(context) }

    it { should be == '<form method="POST" enctype="multipart/form-data"><input type="hidden" name="content_type_slug" value="articles" /><input type="hidden" name="token" value="42" />Hello world</form>' }

    context 'with a css class' do

      let(:options) { '"articles", class: "col-md-12"' }

      it { should include '<form method="POST" enctype="multipart/form-data" class="col-md-12">' }

    end

    context 'with an id (dom)' do

      let(:options) { '"articles", id: "my-form"' }

      it { should include '<form method="POST" enctype="multipart/form-data" id="my-form">' }

    end

    context 'using callbacks' do

      let(:options) { '"articles", success: "/success", error: "/error"' }

      it { should include '<input type="hidden" name="success_callback" value="/success" />' }
      it { should include '<input type="hidden" name="error_callback" value="/error" />' }

    end

  end

end