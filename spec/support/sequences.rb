def random(range=(1..8))
  chars = ["A".."Z","0".."9"].collect { |r| Array(r) }.join
  range.collect { chars[rand(chars.size)] }.join
end

FactoryGirl.define do
  sequence(:email) { |n| "foo#{n}_#{random}@bar.com" }
end
