class FriendsController < ApplicationController
  before_action :authenticate_user!
  helper :friendships  

  def index
    @friends = current_user
                 .friends_relation
                 .where.not(id: current_user.blocked_user_ids)
                 .order(:name)
  end
end
