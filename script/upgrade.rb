#!/usr/bin/env ruby
begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

# Locomotive::Page.each do |page|
#   page.editable_elements.each_with_index do |el, index|
#     next if el._type != 'Locomotive::EditableFile' || el.attributes['source'].is_a?(Hash)
#
#     value = el.attributes['source']
#
#     page.collection.update({ '_id' => page._id }, { '$set' => { "editable_elements.#{index}.source" => { 'en' => value } } })
#   end
# end


# ================ GLOBAL VARIABLES ==============

$database = 'locomotive_hosting_production'

$default_locale = 'en'
# $locale_exceptions = {}

# Example:
$locale_exceptions = {
  '4c082a9393d4330812000002' => 'fr',
  '4c2330706f40d50ae2000005' => 'fr',
  '4dc07643d800a53aea00035a' => 'fr',
  '4eb6aca89a976a0001000ebb' => 'fr'
}

def get_locale(site_id)
  $locale_exceptions[site_id.to_s] || $default_locale
end

# ================ MONGODB ==============

require 'mongoid'

Mongoid.configure do |config|
  name = $database
  host = 'localhost'
  config.master = Mongo::Connection.new.db(name)
  # config.master = Mongo::Connection.new('localhost', '27017', :logger => Logger.new($stdout)).db(name)
end

db = Mongoid.config.master


puts "***************************************"
puts "[LocomotiveCMS] Upgrade from 1.0 to 2.0"
puts "***************************************\n\n"

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
    locale            = get_locale(content_type['site_id'])
    label_field_name  = ''
    recipe            = { 'name' => "Entry#{content_type['_id']}", 'version' => content_type['content_custom_fields_version'], 'rules' => [] }
    rule_options      = {}
    operations        = { '$set' => {}, '$unset' => {} }
    contents          = content_type['contents']
    custom_fields     = content_type['entries_custom_fields']

    # fields
    custom_fields.each_with_index do |field, index|
      name, type = field['_alias'], field['kind'].downcase
      class_name = "Locomotive::Entry#{field['target'][-24,24]}" if field['target']

      case field['kind']
      when 'category'
        type = 'select'
        operations['$set'].merge!("entries_custom_fields.#{index}.type" => 'select')
      when 'has_one'
        type = 'belongs_to'
        operations['$set'].merge!("entries_custom_fields.#{index}.type" => 'belongs_to')
      when 'has_many'
        if field['reverse_lookup']
          type = 'has_many'
          operations['$set'].merge!("entries_custom_fields.#{index}.type" => 'has_many')

          # reverse_lookup -> inverse_of  => hmmmmmmm
          if _content_type = collection.find('_id' => BSON::ObjectId(field['target'][-24,24]).first)
            if _field = _content_type['entries_custom_fields'].detect { |f| f['_name'] == field['reverse_lookup'] }
              operations['$set'].merge!("entries_custom_fields.#{index}.inverse_of" => _field['_alias'])
            end
          end
        else
          type = 'many_to_many'
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
        "entries_custom_fields.#{index}.name"       => field['_alias'],
        "entries_custom_fields.#{index}.type"       => type,
        "entries_custom_fields.#{index}._type"      => 'Locomotive::ContentTypeEntryField',
        "entries_custom_fields.#{index}.localized"  => false
      })

      if field['kind'] == 'category'
        options = field['category_items'].map do |attributes|
          {
            '_id'       => attributes['_id'],
            'name'      => { locale => attributes['name'] },
            'position'  => attributes['position']
          }
        end
        rule_options['select_options'] = options
        operations['$set'].merge!("entries_custom_fields.#{index}.select_options" => options)
      end

      operations['$unset'].merge!({
        "entries_custom_fields.#{index}._name"          => '1',
        "entries_custom_fields.#{index}._alias"         => '1',
        "entries_custom_fields.#{index}.kind"           => '1',
        "entries_custom_fields.#{index}.category_items" => '1',
        "entries_custom_fields.#{index}.format"         => '1'
      })

      recipe['rules'] << {
        'name'      => name,
        'type'      => type,
        'required'  => field['required'] || false,
        'localized' => false
      }.merge(rule_options)
    end

    operations['$set'].merge!({
      'order_by' => '_position'
    }) if content_type['order_by'] == '_position_in_list'

    operations['$unset'].merge!({
      'highlighted_field_name'                        => '1',
      'group_by_field_name'                           => '1'
    })

    # contents
    (contents || []).each_with_index do |content|
      attributes = content.clone.keep_if { |k, v| %w(_id _slug seo_title meta_description meta_keywords _visible created_at updated_at).include?(k) }
      attributes.merge!({
        'content_type_id'       => content_type['_id'],
        'site_id'               => content_type['site_id'],
        '_position'             => content['_position_in_list'],
        '_type'                 => "Locomotive::Entry#{content_type['_id']}",
        '_label_field_name'     => label_field_name,
        'custom_fields_recipe'  => recipe
      })

      custom_fields.each do |field|
        name, _name = field['_alias'], field['_name']

        case field['kind'] # string, text, boolean, date, file, category, has_many, has_one
        when 'string', 'text', 'boolean', 'date'
          attributes[name] = content[_name]
        when 'file'
          attributes[name] = content["#{_name}_filename"]
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
      contents_collection.insert attributes
    end

    # save content_type
    collection.update({ '_id' => content_type['_id'] }, operations)
  end

  collection.update({}, { '$unset' => { 'contents' => '1' } }, :multi => true)
end

# sites -> locomotive_sites
if collection = db.collections.detect { |c| c.name == 'sites' }
  new_collection = db.collections.detect { |c| c.name == 'locomotive_sites' }
  new_collection.drop if new_collection
  collection.rename 'locomotive_sites'

  # localize attributes
  collection.find.each do |site|
    locale = get_locale(site['_id'])

    attributes = { 'locales' => [locale] }

    %w(seo_title meta_keywords meta_description).each do |attr|
      attributes[attr] = { locale => site[attr] }
    end

    collection.update({ '_id' => site['_id'] }, { '$set' => attributes })
  end
end

# snippets -> locomotive_snippets
if collection = db.collections.detect { |c| c.name == 'snippets' }
  new_collection = db.collections.detect { |c| c.name == 'locomotive_snippets' }
  new_collection.drop if new_collection
  collection.rename 'locomotive_snippets'

  # localize template
  collection.find.each do |snippet|
    locale = get_locale(snippet['site_id'])

    collection.update({ '_id' => snippet['_id'] }, { '$set' => { 'template' => { locale => snippet['template'] } } })
  end
end

# theme_assets -> locomotive_theme_assets
if collection = db.collections.detect { |c| c.name == 'theme_assets' }
  new_collection = db.collections.detect { |c| c.name == 'locomotive_theme_assets' }
  new_collection.drop if new_collection
  collection.rename 'locomotive_theme_assets'
end

# accounts -> locomotive_accounts
if collection = db.collections.detect { |c| c.name == 'accounts' }
  new_collection = db.collections.detect { |c| c.name == 'locomotive_accounts' }
  new_collection.drop if new_collection
  collection.rename 'locomotive_accounts'
end

# pages -> locomotive_pages
if collection = db.collections.detect { |c| c.name == 'pages' }
  new_collection = db.collections.detect { |c| c.name == 'locomotive_pages' }
  new_collection.drop if new_collection
  collection.rename 'locomotive_pages'

  parents_table = {}

  collection.find.each do |page|
    parents_table[page['_id']] = page['parent_id']
    locale = get_locale(page['site_id'])

    modifications, removals = {}, {}

    %w(title slug fullpath raw_template serialized_template template_dependencies snippet_dependencies seo_title meta_keywords meta_description).each do |attr|
      modifications[attr] = { locale => page[attr] }
    end

    if page['templatized']
      modifications['target_klass_name'] = "Locomotive::Entry#{page['content_type_id']}"
      removals['content_type_id'] = '1'
    end

    # editable elements
    (page['editable_elements'] || []).each_with_index do |editable_element, index|
      modifications["editable_elements.#{index}._type"]   = "Locomotive::#{editable_element['_type']}"
      modifications["editable_elements.#{index}.content"] = { locale => editable_element['content'] }

      if editable_element['_type'] == 'EditableFile'
        modifications["editable_elements.#{index}.source"] = { locale => editable_element['source_filename'] }
        removals["editable_elements.#{index}.source_filename"] = '1'
      end
    end

    if page['depth'] == 0 && page['fullpath'] == '404'
      modifications['position'] = 1
    end

    collection.update({ '_id' => page['_id'] }, { '$set' => modifications, '$unset' => removals })
  end

  # set parent ids
  collection.find.each do |page|
    parent_ids, page_cursor = [], page['_id']

    while !parents_table[page_cursor].nil?
      parent_ids << parents_table[page_cursor]
      page_cursor = parents_table[page_cursor]
    end

    collection.update({ '_id' => page['_id'] }, { '$set' => { 'parent_ids' => parent_ids.reverse } })
  end

  collection.update({}, { '$unset' => { 'parts' => '1', 'path' => '1', 'layout_id' => '1' } }, { :multi => true })
end

# some cleaning
%w(asset_collections liquid_templates delayed_backend_mongoid_jobs).each do |name|
  db.drop_collection name
end
