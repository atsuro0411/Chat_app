class BlocksController < ApplicationController
    before_action :authenticate_user!

  def index
    @blocked_users = User.where(id: current_user.blocks_given.select(:blocked_id)).order(:name)
  end

  def create
    other_id = params[:user_id].to_i
    return redirect_back fallback_location: friendships_path, alert: "不正なユーザー" if other_id.zero?
    return redirect_back fallback_location: friendships_path, alert: "自分はブロックできません" if other_id == current_user.id

    current_user.block!(User.find(other_id))
    redirect_back fallback_location: friendships_path, notice: "ブロックしました"
  end

  def destroy
    other_id = params[:user_id].to_i
    current_user.unblock!(User.find(other_id))
    redirect_back fallback_location: friendships_path, notice: "ブロック解除しました"
  end
end
