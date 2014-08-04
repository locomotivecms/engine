Locomotive::Wallet.generate_policy_for do
  role :guest do
    policy :translation do
      right(:touch)  { |u, r, m| false }
      right(:create) { |u, r, m| false }
    end
    policy :content_asset do |user, resource|
      right(:touch)  { |u, r, m| false }
      right(:create) { |u, r, m| false }
    end
    policy :site do |user, resource|
      right(:touch)  { |u, r, m| false }
      right(:create) { |u, r, m| false }
    end
    policy :snippet do |user, resource|
      right(:touch)  { |u, r, m| false }
      right(:create) { |u, r, m| false }
    end
    policy :theme_asset do |user, resource|
      right(:touch)  { |u, r, m| false }
      right(:create) { |u, r, m| false }
    end
    policy :membership do |user, resource|
      right(:touch)       { |u, r, m| false }
      right(:create)      { |u, r, m| false }
      right(:grant_admin) { |u, r, m| false }
    end
    scope :account do |user, site, membership|
      []
    end
    scope :site do |user, site, membership|
      [site]
    end
  end
end
