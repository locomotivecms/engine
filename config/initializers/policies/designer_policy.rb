Locomotive::Wallet.generate_policy_for do
  role :designer do
    policy :translation do
      right(:touch)  { |u, r, m| true }
      right(:create) { |u, r, m| true }
    end
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
    policy :membership do |user, resource|
      right(:touch)       { |u, r, m| false }
      right(:create)      { |u, r, m| false }
      right(:grant_admin) { |u, r, m| false }
    end
    scope :site do |user, site, membership|
      [site]
    end
  end
end
