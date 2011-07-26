Bushido::Data.listen("app.claimed") do |event|
  puts "Saving #{Account.first.inspect} with incoming data #{event.inspect}"

  account = Account.first
  account.email = event["data"].try(:[], "email")
  account.save
end
