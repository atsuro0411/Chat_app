class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :groups, through: :group_users
  has_many :group_users

  has_many :posts

  has_many :sent_friendships,     class_name: "Friendship", foreign_key: :requester_id
  has_many :received_friendships, class_name: "Friendship", foreign_key: :addressee_id

  scope :search_by_name, ->(q) { where("name LIKE ?", "%#{q}%") }

  def friends
    ids1 = sent_friendships.accepted.pluck(:addressee_id)
    ids2 = received_friendships.accepted.pluck(:requester_id)
    User.where(id: ids1 + ids2)
  end

  def friend_with?(other)
    Friendship.between(id, other.id).accepted.exists?
  end



  def send_friend_request!(to_user)
    raise "自分には送れません" if id == to_user.id
    if (pair = Friendship.between(id, to_user.id).first)
      case pair.status
      when "pending"
        if pair.requester_id == id
          pair
        else
          pair.accept!
          pair
        end
      when "accepted"
        pair
      when "declined"
        pair.update!(requester_id: id, addressee_id: to_user.id, status: :pending)
        pair
      end
    else
      Friendship.create!(requester_id: id, addressee_id: to_user.id, status: :pending)
    end
  end
end
