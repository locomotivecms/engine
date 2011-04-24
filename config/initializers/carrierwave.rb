require 'locomotive'

# TODO: Make this store to RAILS_ROOT/permanent

# On bushido, the app directory is destroyed on every update, so everything is lost.
# The only place this doesn't happen is the RAILS_ROOT/permanent folder.
# Also, RAILS_ROOT/permanent/store is symlinked to RAILS_ROOT/public/store on every update,
# so store your publicly-accessible files here (e.g. templates, etc.)

CarrierWave.configure do |config|

  config.cache_dir = File.join(Rails.root, 'tmp', 'uploads')

  case Rails.env.to_sym

  when :development
    config.storage = :file
    config.root = File.join(Rails.root, 'public')

  when :production
    if Locomotive.bushido?
      config.storage = :file
      config.root = File.join(Rails.root, 'public')
      config.store_dir = 'store'
    else
      config.storage = :s3
      config.s3_access_key_id = ENV['S3_KEY_ID']
      config.s3_secret_access_key = ENV['S3_SECRET_KEY']
      config.s3_bucket = ENV['S3_BUCKET']
      # config.s3_cname = 'ENV['S3_CNAME']
    end
  end

end unless Locomotive.engine?
