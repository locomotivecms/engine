CarrierWave.configure do |config|

  config.cache_dir = File.join(Rails.root, 'tmp', 'uploads')

  case Rails.env.to_sym

  when :development
    config.storage = :file
    config.root = File.join(Rails.root, 'public')

  when :production
    # WARNING: add the "carrierwave-aws" gem in your Rails app Gemfile.
    # More information here: https://github.com/sorentwo/carrierwave-aws

    config.storage          = :aws
    config.aws_bucket       = ENV['S3_BUCKET']
    config.aws_acl          = 'public-read'

    config.aws_credentials  = {
      access_key_id:      ENV['S3_KEY_ID'],
      secret_access_key:  ENV['S3_SECRET_KEY'],
      region:             ENV['S3_BUCKET_REGION']
    }

    # Use a different endpoint (eg: another provider such as Exoscale)
    if ENV['S3_ENDPOINT'].present?
      config.aws_credentials[:endpoint] = ENV['S3_ENDPOINT']
    end

    # Put your CDN host below instead
    if ENV['S3_ASSET_HOST_URL'].present?
      config.asset_host = ENV['S3_ASSET_HOST_URL']
    end

  else
    # settings for the local filesystem
    config.storage = :file
    config.root = File.join(Rails.root, 'public')
  end

end
