require 'rails_helper'

describe Locomotive do

  describe '.configure' do

    # Configuration settings are class-level, so restore the original values even
    # when validation raises.
    around do |example|
      original_sender = Locomotive.config.mailer_sender
      original_devise = Devise.mailer_sender
      begin
        example.run
      ensure
        Locomotive.config.mailer_sender = original_sender
        Devise.mailer_sender           = original_devise
      end
    end

    def configure_with(sender)
      Locomotive.configure { |config| config.mailer_sender = sender }
    end

    context 'the mailer_sender is a full email address' do
      it 'is accepted and assigned to Devise' do
        configure_with('support@example.com')
        expect(Devise.mailer_sender).to eq('support@example.com')
      end
    end

    context 'the mailer_sender includes a display name' do
      it 'is accepted and assigned verbatim' do
        configure_with('Locomotive <support@example.com>')
        expect(Devise.mailer_sender).to eq('Locomotive <support@example.com>')
      end
    end

    context 'the mailer_sender is only a local part' do
      it 'raises an ArgumentError' do
        expect { configure_with('support') }
          .to raise_error(ArgumentError, /mailer_sender must be a full email address/)
      end
    end

    context 'the mailer_sender is blank' do
      it 'raises an ArgumentError' do
        expect { configure_with('') }.to raise_error(ArgumentError)
      end
    end

    context 'the mailer_sender is syntactically invalid' do
      it 'raises an ArgumentError' do
        expect { configure_with('a@b@c') }.to raise_error(ArgumentError)
      end
    end

  end

end
