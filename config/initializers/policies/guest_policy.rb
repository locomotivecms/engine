Locomotive::Wallet.generate_policy_for do
  role :guest do
    policy :post do
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
  end
end
