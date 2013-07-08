class ApiKeyForAllAccounts < MongoidMigration::Migration
  def self.up
    Locomotive::Account.all.each do |account|
      account.regenerate_api_key!
    end
  end

  def self.down
  end
end