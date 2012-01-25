# http://mislav.uniqpath.com/2010/09/cuking-it-right/

{
  # 'as a movie title in the results' => 'ol.movies h1',
  # 'in a button' => 'button, input[type=submit]',
  # 'in the navigation' => 'nav'
}.
each do |within, selector|
  Then /^(.+) #{within}$/ do |step|
    with_scope(selector) do
      Then step
    end
  end
end
