Locomotive::Wallet.generate_policy_for do
  role :author do
    policy :account do
      right(:touch)  { |u, r, m| u == r }
    end
    policy :content_asset do
      right(:touch)  { |u, r, m| true }
      right(:create) { |u, r, m| true }
    end
    policy :site do |user, resource|
      right(:touch)  do |u, r, m|
        r and r.is_a?(Locomotive::Site) and r.memberships.include?(m)
      end
    end
    policy :snippet do |user, resource|
      right(:touch)  { |u, r, m| true }
      right(:create) { |u, r, m| true }
    end
    policy :theme_asset do |user, resource|
      right(:touch)  { |u, r, m| true }
      right(:create) { |u, r, m| true }
    end

    scope :content_asset do |user, site, membership|
      site.content_assets
    end
    scope :page do |user, site, membership|
      if user.sites.include?(site)
        site.pages
      else
        []
      end
    end
    scope :snippet do |user, site, membership|
      if user.sites.include?(site)
        site.snippets
      else
        []
      end
    end
    scope :theme_asset do |user, site, membership|
      if user.sites.include?(site)
        site.theme_assets
      else
        []
      end
    end
  end
end
