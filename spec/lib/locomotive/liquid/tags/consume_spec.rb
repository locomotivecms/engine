require 'spec_helper'

describe Locomotive::Liquid::Tags::Consume do

  context '#validating syntax' do

    let(:markup) { '' }
    let(:tag) { Locomotive::Liquid::Tags::Consume.new('consume', markup, ["{% endconsume %}"], {}) }
    subject { lambda { tag } }

    describe 'validates a basic syntax' do

      let(:markup) { 'blog from "http://blog.locomotiveapp.org"' }
      it { should_not raise_exception }

    end

    describe 'validates more complex syntax with attributes' do

      let(:markup) { 'blog from "http://www.locomotiveapp.org", username: "john", password: password_from_context' }
      it { should_not raise_exception }

    end

    describe 'should parse the correct url with complex syntax with attributes' do

      let(:markup) { 'blog from "http://www.locomotiveapp.org" username: "john", password: "easyone"' }
      it { should_not raise_exception }
      it { tag.instance_variable_get(:@url).should eq "http://www.locomotiveapp.org" }

    end

    describe 'raises an error if the syntax is incorrect' do

      let(:markup) { 'blog http://www.locomotiveapp.org' }
      it { should raise_exception }

    end

  end

  context '#rendering' do

    let(:assigns)     { {} }
    let(:template)    { '' }
    let(:api_options) { { base_uri: 'http://blog.locomotiveapp.org' } }
    let(:response)    { { 'title' => 'Locomotive rocks !' } }
    let(:mocked_response) { mock('response', code: 200, parsed_response: parsed_response(response)) }

    before { Locomotive::Httparty::Webservice.expects(:get).with('/api/read', api_options).returns(mocked_response) }

    subject { render_template(template, assigns) }

    describe 'assign the response into the liquid variable' do

      let(:template) { "{% consume blog from \"http://blog.locomotiveapp.org/api/read\" %}{{ blog.title }}{% endconsume %}" }
      it { should eq 'Locomotive rocks !' }

    end

    describe 'assign the response into the liquid variable using a url from a variable' do

      let(:assigns)   { { 'url' => 'http://blog.locomotiveapp.org/api/read' } }
      let(:template)  { "{% consume blog from url %}{{ blog.title }}{% endconsume %}" }
      it { should eq 'Locomotive rocks !' }

    end

    describe 'accept options for the web service' do

      let(:assigns)     { { 'secret_password' => 'bar' } }
      let(:api_options) { { base_uri: 'http://blog.locomotiveapp.org', basic_auth: { username: 'foo', password: 'bar' } } }
      let(:template) { "{% consume blog from \"http://blog.locomotiveapp.org/api/read\", username: 'foo', password: secret_password %}{{ blog.title }}{% endconsume %}" }
      it { should eq 'Locomotive rocks !' }

    end

  end

  context 'timeout' do

    let(:url) { 'http://blog.locomotiveapp.org/api/read' }
    let(:template) { %{{% consume blog from "#{url}" timeout:5.0 %}{{ blog.title }}{% endconsume %}} }

    subject { render_template(template) }

    it 'should pass the timeout option to httparty' do
      Locomotive::Httparty::Webservice.expects(:consume).with(url, { timeout: 5.0 })
      subject
    end

    it 'should return the previous successful response if a timeout occurs' do
      Locomotive::Httparty::Webservice.stubs(:consume).returns({ 'title' => 'first response' })
      subject.should eq 'first response'

      Locomotive::Httparty::Webservice.stubs(:consume).raises(Timeout::Error)
      subject.should eq 'first response'
    end

  end

  def parsed_response(attributes)
    OpenStruct.new(underscore_keys: attributes)
  end

  def render_template(template, assigns = {})
    _context = Liquid::Context.new(assigns, {}, {})
    Liquid::Template.parse(template).render(_context)
  end
end
