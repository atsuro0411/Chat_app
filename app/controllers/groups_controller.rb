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
    selected_ids = (Array(params[:user_ids]) + [ params[:user_id] ]).map(&:to_i)

    user_ids = Group.build_user_ids(selected_ids, current_user.id)
    group_id = Group.id_for_exact_members(user_ids)

    if group_id.present?
      redirect_to group_path(group_id), notice: "グループに入室しました"
    else
      names = User.where(id: user_ids).pluck(:name)
      group_name =
        if names.size <= 2
          names.join(",")
        else
          "#{names.first(2).join(",")}..."
        end

      group = Group.create(name: group_name)
      user_ids = (selected_ids + [ current_user.id ]).uniq
      user_ids.each do |user_id|
      GroupUser.create(user_id: user_id, group_id: group.id)
    end


      redirect_to group_path(group), notice: "グループを作成しました"
    end
  end
end
