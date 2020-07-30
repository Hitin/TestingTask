FactoryBot.define do
  sequence :string, aliases: [:title, :body] do |n|
    "string#{n}"
  end
end
