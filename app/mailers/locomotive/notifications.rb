module Locomotive
  class Notifications < ActionMailer::Base

    default :from => Locomotive.config.mailer_sender

    def new_content_entry(entry, account)
      @account, @entry, @type = account, entry, entry.content_type

      subject = t('locomotive.notifications.new_content_entry.subject', :type => @type.name, :locale => account.locale)

      mail :subject => subject, :to => account.email
    end
  end

end