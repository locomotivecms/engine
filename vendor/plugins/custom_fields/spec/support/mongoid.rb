Mongoid.configure do |config|
  name = "custom_fields_test"
  host = "localhost"
  config.master = Mongo::Connection.new.db(name)
  # config.master = Mongo::Connection.new('localhost', '27017', :logger => Logger.new($stdout)).db(name)
end