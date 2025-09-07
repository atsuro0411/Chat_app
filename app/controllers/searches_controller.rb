class SearchesController < ApplicationController
  before_action :authenticate_user!
  helper :friendships

  def users
    @q = params[:q].to_s
    blocked_ids = current_user.blocks_given.pluck(:blocked_id) + current_user.blocks_received.pluck(:blocker_id)
    base = User.where.not(id: [ current_user.id ] + blocked_ids)
    @users = @q.blank? ? [] : base.search_by_name(@q).order(:name)
  end

  def friends
    @q = params[:q].to_s
    blocked_ids = current_user.blocks_given.pluck(:blocked_id) + current_user.blocks_received.pluck(:blocker_id)
    friend_ids  = current_user.friends.where.not(id: blocked_ids).select(:id)
    @friends = @q.blank? ? [] : User.where(id: friend_ids).merge(User.search_by_name(@q)).order(:name)
  end
end
