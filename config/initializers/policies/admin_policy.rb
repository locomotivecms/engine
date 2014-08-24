Locomotive::Wallet.generate_policy_for do
  role :admin do
    policy :translation do
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
    policy :membership do |user, resource|
      right(:touch)       { |u, r, m| true }
      right(:create)      { |u, r, m| true }
      right(:grant_admin) { |u, r, m| true }
    end
    scope :accounts do |user, site, membership|
      site.accounts
    end
    scope :sites do |user, site, membership|
      user.sites
    end
  end
end
