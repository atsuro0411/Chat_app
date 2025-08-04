class Group < ApplicationRecord
  has_many :group_users
  has_many :users, thurough: :group_users

  has_many :posts
end
