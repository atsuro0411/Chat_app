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
    selected_ids = []
    selected_ids += Array(params[:user_ids]).map(&:to_i)
    selected_ids << params[:user_id].to_i if params[:user_id].present?
    
    if selected_ids.blank?
      redirect_to new_group_path, alert: "メンバーを選択してください"
      return
    end
      user_ids = (selected_ids + [current_user.id]).uniq
      group_users = GroupUser.where(user_id: user_ids)
      grouped =group_users.group_by { |group_user| group_user.group_id }
      group_id = grouped.find { |group_id, users|users.map(&:user_id).uniq.sort == user_ids.sort }&.first
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
