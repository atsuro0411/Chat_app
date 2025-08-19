class Group < ApplicationRecord
  has_many :group_users
  has_many :users, through: :group_users

  has_many :posts


  def Group.build_user_ids(selected_ids, current_user_id)
    (Array(selected_ids).map(&:to_i) + [ current_user_id ]).uniq.sort
  end


  def Group.id_for_exact_members(user_ids)
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

  def update_default_name(user_ids: nil)
    return if name.present?

    names =
      if user_ids
        User.where(id: user_ids).pluck(:name)
      else
        users.reload.pluck(:name)
      end

    new_name =
      if names.size <= 2
        names.join("、")
      else
        "#{names.first(2).join("、")}..."
      end

    update!(name: new_name)
  end
end
