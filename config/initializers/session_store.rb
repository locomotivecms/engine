# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key    => '_locomotive_session',
  :secret => 'f2049860ac1a8b742808d738ac8a15db5d4be22526f4e497037973f19f59f3b46ae5c97df01cac6637821a9f4aedf9436ceba10e126a4eb278461a03828bf06f'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
