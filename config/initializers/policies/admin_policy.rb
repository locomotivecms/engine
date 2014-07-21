Locomotive::Wallet.generate_policy_for do
  role :admin do
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
  end
end
