class Locomotive.Models.Account extends Backbone.Model

  paramRoot: 'account'

  urlRoot: "#{Locomotive.mounted_on}/accounts"

class Locomotive.Models.CurrentAccount extends Locomotive.Models.Account

  url: "#{Locomotive.mounted_on}/my_account"


