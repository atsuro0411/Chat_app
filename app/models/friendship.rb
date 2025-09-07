class Friendship < ApplicationRecord
 belongs_to :requester, class_name: "User"
  belongs_to :addressee, class_name: "User"

  enum :status, { pending: 0, accepted: 1, declined: 2 }

  validates :requester_id, uniqueness: { scope: :addressee_id }
  validates :addressee_id, comparison: { other_than: :requester_id, message: "に自分は指定できません" }
  validate  :no_inverse_pending, on: :create
   validate :not_blocked_either, on: :create

  scope :connecting, ->(a_id, b_id) {
    where(requester_id: a_id, addressee_id: b_id)
      .or(where(requester_id: b_id, addressee_id: a_id))
  }

  def accept!  = update!(status: :accepted)
  def decline! = update!(status: :declined)

  private

  def no_inverse_pending
    if self.class.pending.exists?(requester_id: addressee_id, addressee_id: requester_id)
      errors.add(:base, "相手からの申請が保留中です")
    end
  end

  def not_blocked_either
    if Block.connecting_block(requester_id, addressee_id).exists?
      errors.add(:base, "ブロック中のため申請できません")
    end
  end
end
