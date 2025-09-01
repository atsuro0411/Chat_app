class Group < ApplicationRecord
  has_many :group_users
  has_many :users, through: :group_users

  has_many :posts


  def self.build_user_ids(selected_ids, current_user_id)
    (Array(selected_ids).map(&:to_i) + [ current_user_id ]).uniq.sort
  end


  def self.id_for_exact_members(user_ids)
    ids = Array(user_ids).map(&:to_i).uniq.sort
    return nil if ids.blank?

    joins(:group_users)
      .group("groups.id")
      .having(
        "COUNT(DISTINCT group_users.user_id) = ? AND " \
        "COUNT(DISTINCT CASE WHEN group_users.user_id IN (?) " \
        "THEN group_users.user_id END) = ?",
        ids.size, ids, ids.size
      )
      .pick("groups.id")
  end
end
