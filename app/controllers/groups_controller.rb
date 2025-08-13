class GroupsController < ApplicationController
  def new
    @users = User.where.not(id: current_user.id)
  end

  def show
    @group = Group.find(params[:id])
    @post = Post.new
    @posts = @group.posts.all
  end


  def create
    selected_ids = Array(params[:user_ids]).map(&:to_i)
    selected_ids << params[:user_id].to_i if params[:user_id].present?

    if selected_ids.blank?
      redirect_to new_group_path, alert: "メンバーを選択してください"
      return
    end

      user_ids = (selected_ids + [ current_user.id ]).uniq.sort
      
      group_id = Group
        .joins(:group_users)
        .group('groups.id')
        .having(
          'COUNT(DISTINCT group_users.user_id) = ? AND ' \
          'COUNT(DISTINCT CASE WHEN group_users.user_id IN (?) THEN group_users.user_id END) = ?',
          user_ids.size, user_ids, user_ids.size
        )
        .pluck('groups.id')
        .first

    if group_id.present?
      @group = Group.find(group_id)
      redirect_to group_path(@group), notice: "グループに入室しました"
    else
      names = User.where(id: user_ids).pluck(:name)
      group_name = names.size <= 2 ? names.join("、") : "#{names.first(2).join("、")}..."
      @group= Group.create(name: group_name)
      user_ids.each do |user_id|
        GroupUser.create(user_id: user_id, group_id: @group.id)
      end
        redirect_to group_path(@group), notice: "グループを作成しました"
    end
  end
end
