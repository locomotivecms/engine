require_relative 'entities/base_entity'
Dir[File.dirname(__FILE__) + '/entities/*.rb'].each { |file| require file }
