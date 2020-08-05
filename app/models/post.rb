class Post < ApplicationRecord
  validates :title, :body, :user_id, presence: true
end
