class Block < ApplicationRecord
  belongs_to :blocker, class_name: "User"
  belongs_to :blocked, class_name: "User"

  validates :blocker_id, uniqueness: { scope: :blocked_id }
  validate  :not_self

  scope :connecting_block, ->(a_id, b_id) {
    where(blocker_id: a_id, blocked_id: b_id)
      .or(where(blocker_id: b_id, blocked_id: a_id))
  }

  private
  def not_self
    errors.add(:base, "自分自身をブロックできません") if blocker_id == blocked_id
  end
end
