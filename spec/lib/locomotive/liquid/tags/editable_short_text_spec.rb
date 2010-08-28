require 'spec_helper'

describe Locomotive::Liquid::Tags::EditableShortText do

  it 'should have a valid syntax' do
    markup = "'title', hint: 'Simple short text'"
    Locomotive::Liquid::Tags::EditableShortText.any_instance.stubs(:end_tag).returns(true)
    lambda do
      Locomotive::Liquid::Tags::EditableShortText.new('editable_short_text', markup, ["{% endeditable_short_text %}"], {})
    end.should_not raise_error
  end

  # it 'should raise an error if the syntax is incorrect' do
  #   ["contents.projects by a", "contents.projects", "contents.projects 5"].each do |markup|
  #     lambda do
  #       Locomotive::Liquid::Tags::Paginate.new('paginate', markup, ["{% endpaginate %}"], {})
  #     end.should raise_error
  #   end
  # end

end
