File.open(File.join(Rails.root, 'config/database.yml'), 'r') do |f|
  @settings = YAML.load(f)[Rails.env]
end

Mongoid.configure do |config|
  name = @settings["database"]
  host = @settings["host"]
  config.master = Mongo::Connection.new.db(name)
  # config.slaves = [
  #   Mongo::Connection.new(host, @settings["slave_one"]["port"], :slave_ok => true).db(name),
  #   Mongo::Connection.new(host, @settings["slave_two"]["port"], :slave_ok => true).db(name)
  # ]
end
