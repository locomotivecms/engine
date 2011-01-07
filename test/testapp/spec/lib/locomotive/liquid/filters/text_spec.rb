require 'spec_helper'

describe Locomotive::Liquid::Filters::Text do

  include Locomotive::Liquid::Filters::Text

  it 'transforms a textile input into HTML' do
    textile('This is *my* text.').should == "<p>This is <strong>my</strong> text.</p>"
  end

end
