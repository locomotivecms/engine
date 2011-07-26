Bushido::Data.listen("app.claimed") do |data|
  puts "Saving #{Account.first.inspect} with incoming data #{data.inspect}"

  account = Account.first
  account.email = data["email"]
  account.save
end
