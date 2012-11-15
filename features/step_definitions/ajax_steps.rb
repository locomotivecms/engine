
def wait_for_ajax(&block)
  start_time = Time.now
  while Time.now < start_time + Capybara.default_wait_time
    begin
      block.call
      break
    rescue
      # Try again
    end
  end
end

Then /^after the AJAX finishes, (.*)$/ do |*args|
  step_str = args[0]
  step_arg = args[1]
  wait_for_ajax do
    step(step_str, step_arg)
  end
end
