module Locomotive
  module AccountsHelper

    def options_for_account
      current_site.accounts.collect { |a| ["#{a.name} <#{a.email}>", a.id.to_s] }
    end

    def account_avatar_and_name(account, size = '70x70#')
      avatar  = image_tag(account_avatar_url(account, size), class: 'img-circle', style: 'width: 20px')
      profile = avatar + account.name
    end

  end
end
