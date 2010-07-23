account = Account.create! :name => 'Admin', :email => 'admin@example.com', :password => 'locomotive', :password_confirmation => 'locomotive'

site = Site.new :name => 'Locomotive test website', :subdomain => 'test'
site.memberships.build :account => account, :admin => true
site.save!

puts "Your first website has been created !"
puts "Admin url: http://test.example.com:3000/admin"
puts "Crendetials: admin@example.com / locomotive"
