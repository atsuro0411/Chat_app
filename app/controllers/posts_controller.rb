class PostsController < ApplicationController
  def create
    group = Group.find(params[:group_id])
    @post = Post.new(post_params)
    @post.user_id = current_user.id
    @post.group_id = group.id

    if @post.save

      redirect_to group_path(group)

    else
      redirect_to group_path(group)
    end
  end

  private

  def post_params
    params.require(:post).permit(:content)
  end
end
