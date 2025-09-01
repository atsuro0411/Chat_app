class SearchesController < ApplicationController
  before_action :authenticate_user!
  helper :friendships

  def users
    @q = params[:q].to_s
    @users = User.where.not(id: current_user.id)
                 .merge(User.search_by_name(@q))
                 .order(:name)
  end


  def friends
    @q = params[:q].to_s
    friend_ids = Friendship.accepted.where(requester_id: current_user.id).pluck(:addressee_id) +
                 Friendship.accepted.where(addressee_id: current_user.id).pluck(:requester_id)
    @friends = User.where(id: friend_ids.uniq)
                   .merge(User.search_by_name(@q))
                   .order(:name)
  end
end
