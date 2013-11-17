require 'spec_helper'

describe Locomotive::Liquid::Tags::Consume do

  context '#validating syntax' do

    it 'validates a basic syntax' do
      markup = 'blog from "http://blog.locomotiveapp.org"'
      lambda do
        Locomotive::Liquid::Tags::Consume.new('consume', markup, ["{% endconsume %}"], {})
      end.should_not raise_error
    end

    it 'validates more complex syntax with attributes' do
      markup = 'blog from "http://www.locomotiveapp.org" username: "john", password: "easyone"'
      lambda do
        Locomotive::Liquid::Tags::Consume.new('consume', markup, ["{% endconsume %}"], {})
      end.should_not raise_error
    end

    it 'should parse the correct url with complex syntax with attributes' do
      markup = 'blog from "http://www.locomotiveapp.org" username: "john", password: "easyone"'
      tag = Locomotive::Liquid::Tags::Consume.new('consume', markup, ["{% endconsume %}"], {})
      tag.instance_variable_get(:@url).should == "http://www.locomotiveapp.org"
    end

    it 'raises an error if the syntax is incorrect' do
      markup = 'blog http://www.locomotiveapp.org'
      lambda do
        Locomotive::Liquid::Tags::Consume.new('consume', markup, ["{% endconsume %}"], {})
      end.should raise_error
    end

  end

  context '#rendering' do

    it 'puts the response into the liquid variable' do
      response = mock('response', code: 200, parsed_response: parsed_response('title' => 'Locomotive rocks !'))
      Locomotive::Httparty::Webservice.stubs(:get).returns(response)
      template = "{% consume blog from \"http://blog.locomotiveapp.org/api/read\" %}{{ blog.title }}{% endconsume %}"
      Liquid::Template.parse(template).render.should == 'Locomotive rocks !'
    end

    it 'puts the response into the liquid variable using a url from a variable' do
      response = mock('response', code: 200, parsed_response: parsed_response('title' => 'Locomotive rocks !'))
      Locomotive::Httparty::Webservice.stubs(:get).returns(response)
      template = "{% consume blog from url %}{{ blog.title }}{% endconsume %}"
      Liquid::Template.parse(template).render('url' => "http://blog.locomotiveapp.org/api/read").should == 'Locomotive rocks !'
    end

    it 'puts the response into the liquid variable using a url from a variable that changes within an iteration' do
      base_uri = 'http://blog.locomotiveapp.org'
      template = "{% consume blog from url %}{{ blog.title }}{% endconsume %}"
      compiled_template = Liquid::Template.parse(template)

      [['/api/read', 'Locomotive rocks !'], ['/api/read_again', 'Locomotive still rocks !']].each do |path, title|
        response = mock('response', code: 200, parsed_response: parsed_response('title' => title))
        Locomotive::Httparty::Webservice.stubs(:get).with(path, {:base_uri => base_uri}).returns(response)
        compiled_template.render('url' => base_uri + path).should == title
      end
    end
  end

  context 'timeout' do

    before(:each) do
      @url = 'http://blog.locomotiveapp.org/api/read'
      @template = %{{% consume blog from "#{@url}" timeout:5 %}{{ blog.title }}{% endconsume %}}
    end

    it 'should pass the timeout option to httparty' do
      Locomotive::Httparty::Webservice.expects(:consume).with(@url, {timeout: 5.0})
      Liquid::Template.parse(@template).render
    end

    it 'should return the previous successful response if a timeout occurs' do
      Locomotive::Httparty::Webservice.stubs(:consume).returns({ 'title' => 'first response' })
      template = Liquid::Template.parse(@template)

      template.render.should == 'first response'

      Locomotive::Httparty::Webservice.stubs(:consume).raises(Timeout::Error)
      template.render.should == 'first response'
    end

  end

  def parsed_response(attributes)
    OpenStruct.new(underscore_keys: attributes)
  end
end
