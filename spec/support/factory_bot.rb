RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    FactoryBot.definition_file_paths << Pathname.new(File.join(File.dirname(__FILE__), '..', 'factories'))
    FactoryBot.find_definitions
  end
end

def random(range = (1..8))
  chars = ["A".."Z","0".."9"].collect { |r| Array(r) }.join
  range.collect { chars[rand(chars.size)] }.join
end

FactoryBot.define do

  sequence :email do |n|
    "foo#{n}@bar.com"
  end

  sequence :handle do |n|
    "handle-#{random}-#{n}"
  end

  sequence :name do |n|
    "name_#{random}_#{n}"
  end
end
