class GroupsController < ApplicationController
  def show
    @group = Group.find(params[:id])
    @post = Post.new
  end


  def create
    current_user = User.find(params[:current_user_id])
    user = User.find(params[:user_id])
    group_name = "#{current_user.name}と#{user.name}のトークルーム"
    @group= Group.new(name: group_name)
    if @group.save
        user_ids = [ params[:current_user_id], params[:user_id] ]
        user_ids.each do |user_id|
          GroupUser.create(user_id: user_id, group_id: @group.id)
        end
        redirect_to group_path(@group), notice: "グループを作成しました"
    else
        render :new, status: :unprocessable_entity
    end
  end
end
