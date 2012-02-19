#!/usr/bin/env ruby
begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'mongoid'

Mongoid.configure do |config|
  name = 'locomotive_hosting_production'
  host = 'localhost'
  # config.master = Mongo::Connection.new.db(name)
  config.master = Mongo::Connection.new('localhost', '27017', :logger => Logger.new($stdout)).db(name)
end

puts "***************************************"
puts "[LocomotiveCMS] Upgrade from 1.0 to 2.0"
puts "***************************************\n\n"

db = Mongoid.config.master

# assets -> locomotive_content_assets
if collection = db.collections.detect { |c| c.name == 'assets' }
  new_collection = db.collections.detect { |c| c.name == 'locomotive_content_assets' }
  new_collection.drop if new_collection
  collection.rename 'locomotive_content_assets'
end

# content_types -> locomotive_content_types
if collection = db.collections.detect { |c| c.name == 'content_types' }
  new_collection = db.collections.detect { |c| c.name == 'locomotive_content_types' }
  new_collection.drop if new_collection
  collection.rename 'locomotive_content_types'

  contents_collection = db.collections.detect { |c| c.name == 'locomotive_content_entries' }
  contents_collection = db.create_collection('locomotive_content_entries') if contents_collection.nil?

  collection.update({}, {
    '$rename' => {
      'api_enabled'                   => 'public_submission_enabled',
      'api_accounts'                  => 'public_submission_accounts',
      'content_custom_fields'         => 'entries_custom_fields',
      'content_custom_fields_version' => 'entries_custom_fields_version',
    },
    '$unset' => {
      'content_custom_fields_counter' => '1'
    }
  }, :multi => true)

  collection.find.each do |content_type|
    puts "_________________________________"
    puts "[content_type: #{content_type['name']}] = #{content_type.keys.inspect}"

    label_field_name  = ''
    operations        = { '$set' => {}, '$unset' => {} }
    contents          = content_type['contents']
    custom_fields     = content_type['entries_custom_fields']

    puts "\n*** field keys = #{custom_fields.first.keys.inspect} ***\n\n"

    # fields
    custom_fields.each_with_index do |field, index|
      # puts "field #{field['_alias']}.#{index} (#{field['kind']})"

      next if field['kind'].blank? # already done

      class_name = "Locomotive::Entry#{field['target'][-24,24]}" if field['target']

      case field['kind']
      when 'category'
        operations['$set'].merge!("entries_custom_fields.#{index}.type" => 'select')
      when 'has_one'
        operations['$set'].merge!("entries_custom_fields.#{index}.type" => 'belongs_to')
      when 'has_many'
        if field['reverse_lookup']
          operations['$set'].merge!("entries_custom_fields.#{index}.type" => 'has_many')

          # reverse_lookup -> inverse_of  => hmmmmmmm
          if _content_type = collection.find('_id' => BSON::ObjectId(field['target'][-24,24]).first)
            if _field = _content_type['entries_custom_fields'].detect { |f| f['_name'] == field['reverse_lookup'] }
              operations['$set'].merge!("entries_custom_fields.#{index}.inverse_of" => _field['_alias'])
            end
          end
        else
          operations['$set'].merge!("entries_custom_fields.#{index}.type" => 'many_to_many')
        end
      end

      if %w(has_one has_many).include?(field['kind'])
        operations['$set'].merge!("entries_custom_fields.#{index}.class_name" => class_name)
        operations['$unset'].merge!({
          "entries_custom_fields.#{index}.target"         => '1',
          "entries_custom_fields.#{index}.reverse_lookup" => '1'
        })
      end

      if content_type['highlighted_field_name'] == field['_name']
        operations['$set'].merge!({
          'label_field_id'    => field['_id'],
          'label_field_name'  => field['_alias']
        })
        label_field_name = field['_alias']
      end

      if content_type['group_by_field_name'] == field['_name']
        operations['$set'].merge!('group_by_field_id' => field['_id'])
      end

      operations['$set'].merge!({
        "entries_custom_fields.#{index}.name" => field['_alias'],
        "entries_custom_fields.#{index}.type" => field['kind']
      })

      operations['$set'].merge!({
        "entries_custom_fields.#{index}.select_options" => field['category_items']
      }) if field['kind'] == 'category'

      operations['$unset'].merge!({
        "entries_custom_fields.#{index}._name"          => '1',
        "entries_custom_fields.#{index}._alias"         => '1',
        "entries_custom_fields.#{index}.kind"           => '1',
        "entries_custom_fields.#{index}.category_items" => '1'
      })
    end

    operations['$set'].merge!({
      'order_by' => '_position'
    }) if content_type['order_by'] == '_position_in_list'

    operations['$unset'].merge!({
      'highlighted_field_name'                        => '1',
      'group_by_field_name'                           => '1'
    })

    # contents
    if contents.nil?
      puts "CONTENTS SKIPPED"
      next
    end

    contents.each_with_index do |content|
      attributes = content.clone.keep_if { |k, v| %w(_id _slug seo_title meta_description meta_keywords _visible created_at updated_at).include?(k) }
      attributes.merge!({
        'content_type_id'     => content_type['_id'],
        'site_id'             => content_type['site_id'],
        '_position'           => content['_position_in_list'],
        '_type'               => "Locomotive::Entry#{content_type['_id']}",
        '_label_field_name'   => label_field_name
      })

      custom_fields.each do |field|
        name, _name = field['_alias'], field['_name']

        case field['kind'] # string, text, boolean, date, file, category, has_many, has_one
        when 'string', 'text', 'boolean', 'date'
          attributes[name] = content[_name]
        when 'file'
          attributes[name] = "#{content[_name]}_filename"
        when 'category', 'has_one'
          attributes["#{name}_id"] = content[_name]
        when 'has_many'
          if field['reverse_lookup']
            # nothing to do
          else
            attributes["#{name}_ids"] = content[_name]
          end
        end
      end

      # insert document
      # puts "[INSERTING] ===> #{attributes.inspect}"
      contents_collection.insert attributes
    end

    # TODO: change highlighted_field_name + for each field, change category -> select

    # save content_type
    collection.update({ '_id' => content_type['_id'] }, operations)

    # puts operations.inspect

    puts "================================= END ========================="

    # raise 'END'
  end

  collection.update({}, {
    '$unset' => {
      'contents' => '1'
    }
  }, :multi => true)
end


# TODO
# x relaunch with a fresh db
# x inverse_of can not work if we commit changes before
# x insert contents
# - assets
# -
#
