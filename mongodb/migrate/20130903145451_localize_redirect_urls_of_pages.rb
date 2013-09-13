class LocalizeRedirectUrlsOfPages < MongoidMigration::Migration
  def self.up
    Locomotive::Site.all.each do |site|
      puts "[#{site.name}] - #{site.default_locale} / #{site.locales}"

      site.pages.each do |page|
        next if page.attributes['redirect_url'].is_a?(Hash) # already translated

        puts "\tPage #{page.id} is not translated"

        self.update_page(site, page)
      end
    end
  end

  def self.down
    Locomotive::Page.all.each do |page|
      selector      = { '_id' => page._id }
      modifications = page.attributes['redirect_url'].values.first

      Locomotive::Page.collection.find(selector).update({ '$set' => { 'redirect_url' => modifications } })
    end
  end

  # 2 cases:
  # - not translated, set the redirect_url for all the locales of the site
  # - already translated copy the SAME redirect_url for all the locales of the page
  #
  def self.update_page(site, page)
    selector      = { '_id' => page._id }
    modifications = {}
    redirect_url  = Mongoid::Fields::I18n.with_locale(site.default_locale) { page.redirect_url }

    locales = page.translated? ? page.translated_in : site.locales

    locales.each do |locale|
      modifications[locale.to_s] = redirect_url
    end

    Locomotive::Page.collection.find(selector).update({ '$set' => { 'redirect_url' => modifications } })
  end
end
