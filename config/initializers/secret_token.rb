# Be sure to restart your server when you modify this file.
require 'digest/sha1'

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
token = ENV['BUSHIDO_SALT'] || 'aa84844b97e90edda8e005a686d82c3bef1f8e20a1255301f1d0886fc592a45ef2393d64b0c3d3ea858b1f6406ad6f15305666264716a79fcfa17de93ad0d69d'
Rails.application.config.secret_token = Digest::SHA1.hexdigest(token)
