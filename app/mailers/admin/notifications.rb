module Admin
  class Notifications < ActionMailer::Base

    default :from => Locomotive.config.mailer_sender

    def new_content_instance(account, content)
      @account, @content = account, content

      subject = t('admin.notifications.new_content_instance.subject', :type => content.content_type.name, :locale => account.locale)

      mail :subject => subject, :to => account.email
    end
  end

end