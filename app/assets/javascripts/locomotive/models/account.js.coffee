class Locomotive.Models.Account extends Backbone.Model

  paramRoot: 'account'

  urlRoot: "#{Locomotive.mount_on}/accounts"

class Locomotive.Models.CurrentAccount extends Locomotive.Models.Account

  url: "#{Locomotive.mount_on}/my_account"


