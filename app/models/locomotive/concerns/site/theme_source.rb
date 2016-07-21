module Locomotive
  module Concerns
    module Site
      module ThemeSource

        extend ActiveSupport::Concern

        included do

          ## fields ##
          field :is_theme,          type: Boolean,  default: false
          field :theme_name,        type: String,   default: ''

          scope :themes, -> { where('metafields_ui.is_theme' => true) }

          # FIXME - refactoring in progress
          def activate_theme(from)
            %w{content_types pages snippets theme_assets}.each {|x| self.send(x).delete_all}

            from_site = Locomotive::Site.find from
            dummy = []
            from_site.content_types.each do |c|
              c.as_document["site_id"] = self.id
              c.as_document["number_of_entries"] = 0
              c.as_document.delete "_id"
              dummy << c.as_document
            end
            Locomotive::ContentType.collection.insert_many(dummy)

            dummy = []
            from_site.pages.each do |c|
              c.as_document["site_id"] = self.id
              c.as_document.delete "_id"
              dummy << c.as_document
            end
            Locomotive::Page.collection.insert_many(dummy)

            dummy = []
            from_site.snippets.each do |c|
              c.as_document["site_id"] = self.id
              c.as_document.delete "_id"
              dummy << c.as_document
            end
            Locomotive::Snippet.collection.insert_many(dummy)

            dummy = []
            from_site.theme_assets.each do |c|
              c.as_document["site_id"] = self.id
              c.as_document.delete "_id"
              dummy << c.as_document
            end
            Locomotive::ThemeAsset.collection.insert_many(dummy)

            FileUtils::mkdir_p  "#{Rails.root}/public/sites/#{self.id.to_s}/theme/"
            FileUtils.cp_r "#{Rails.root}/public/sites/#{from_site.id.to_s}/theme/.", "#{Rails.root}/public/sites/#{self.id.to_s}/theme/."

          end

        end

      end
    end
  end
end
