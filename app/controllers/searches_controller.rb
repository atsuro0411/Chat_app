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
  @q = params[:q].to_s.strip

  blocked_ids = (current_user.blocks_given.pluck(:blocked_id) +
                 current_user.blocks_received.pluck(:blocker_id)).uniq

  base = current_user.friends.where.not(id: blocked_ids)

  @friends =
    if @q.present?
      base.merge(User.search_by_name(@q)).order(:name)
    else
      base.order(:name)
    end
end
end
