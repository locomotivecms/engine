require_relative 'forms/base_form'
Dir[File.dirname(__FILE__) + '/forms/*.rb'].each { |file| require file }
