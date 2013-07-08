class LocalizeSlugsOfContentEntries < MongoidMigration::Migration
  def self.up
    Locomotive::Site.all.each do |site|
      puts "[#{site.name}] - #{site.default_locale} / #{site.locales}"

      site.content_entries.each do |entry|
        next if entry.attributes['_slug'].is_a?(Hash) # already translated

        puts "\t#{entry._label} is not translated"

        self.update_entry(site, entry)
      end
    end
  end

  def self.down
    Locomotive::ContentEntry.all.each do |entry|
      selector      = { '_id' => entry._id }
      modifications = entry.attributes['_slug'].values.first

      Locomotive::ContentEntry.collection.find(selector).update({ '$set' => { '_slug' => modifications } })
    end
  end

  # 2 cases:
  # - not translated, set the slug for all the locales of the site
  # - already translated copy the SAME slug for all the locales of the entry
  #
  def self.update_entry(site, entry)
    selector      = { '_id' => entry._id }
    modifications = {}
    slug          = Mongoid::Fields::I18n.with_locale(site.default_locale) { entry._slug }

    locales = entry.localized? ? entry.translated_in : site.locales

    locales.each do |locale|
      modifications[locale.to_s] = slug
    end

    Locomotive::ContentEntry.collection.find(selector).update({ '$set' => { '_slug' => modifications } })
  end

end