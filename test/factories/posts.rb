FactoryBot.define do
  factory :post do
    title
    body
    user_id { '1' }
  end
end
