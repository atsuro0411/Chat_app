class GroupUser < ApplicationRecord
  belongs_to :user
  belongs_to :group

  after_create :set_group_name

  private

  def set_group_name
    group.update_default_name
  end
end
