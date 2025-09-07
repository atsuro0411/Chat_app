class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :groups, through: :group_users
  has_many :group_users

  has_many :posts

  has_many :sent_friendships,     class_name: "Friendship", foreign_key: :requester_id
  has_many :received_friendships, class_name: "Friendship", foreign_key: :addressee_id

  has_many :blocks_given,    class_name: "Block", foreign_key: :blocker_id
  has_many :blocks_received, class_name: "Block", foreign_key: :blocked_id

  scope :search_by_name, ->(q) { where("name LIKE ?", "%#{q}%") }

  def friends
    ids1 = sent_friendships.accepted.pluck(:addressee_id)
    ids2 = received_friendships.accepted.pluck(:requester_id)
    User.where(id: ids1 + ids2)
  end

  def friend_with?(other)
    Friendship.connecting(id, other.id).accepted.exists?
  end

  def send_friend_request!(to_user)
    raise "自分には送れません" if id == to_user.id
    if (pair = Friendship.connecting(id, to_user.id).first)
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

    def block!(other)
    return if other.id == id
    transaction do
      Block.find_or_create_by!(blocker: self, blocked: other)
      Friendship.connecting(id, other.id).destroy_all
    end
  end

  def unblock!(other)
    Block.find_by(blocker: self, blocked: other)&.destroy!
  end

  def blocking?(other)   = blocks_given.exists?(blocked_id: other.id)
  def blocked_by?(other) = blocks_received.exists?(blocker_id: other.id)
  def blocked_with?(other)
    blocking?(other) || blocked_by?(other)
  end
end
