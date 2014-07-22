Locomotive::Wallet.generate_policy_for do
  role :admin do
    policy :translation do
      right(:touch)  { |u, r, m| true }
      right(:create) { |u, r, m| true }
    end
    policy :post do
      right(:touch)  { |u, r, m| true }
      right(:create) { |u, r, m| true }
    end
    policy :content_asset do |user, resource|
      right(:touch)  { |u, r, m| true }
      right(:create) { |u, r, m| true }
    end
    policy :site do |user, resource|
      right(:touch)  { |u, r, m| true }
      right(:create) { |u, r, m| true }
    end
    policy :snippet do |user, resource|
      right(:touch)  { |u, r, m| true }
      right(:create) { |u, r, m| true }
    end
    policy :theme_asset do |user, resource|
      right(:touch)  { |u, r, m| true }
      right(:create) { |u, r, m| true }
    end
    policy :account do |user, resource|
      right(:touch)  { |u, r, m| true }
      right(:create) { |u, r, m| true }
    end

    scope :content_asset do |user, site, membership|
      site.content_assets
    end
    scope :account do |user, site, membership|
      Locomotive::Account
    end
    scope :page do |user, site, membership|
      site.pages
    end
    scope :snippet do |user, site, membership|
      site.snippets
    end
    scope :theme_asset do |user, site, membership|
      site.theme_assets
    end
    scope :translation do |user, site, membership|
      site.translations
    end
  end
end
