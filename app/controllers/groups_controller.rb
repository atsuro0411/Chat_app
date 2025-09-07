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
    selected_ids = (Array(params[:user_ids]) + [ params[:user_id] ]).compact.map(&:to_i).uniq
    return redirect_to new_group_path, alert: "メンバーを選択してください" if selected_ids.blank?

    user_ids = (selected_ids + [ current_user.id ]).uniq.sort
    others   = user_ids - [ current_user.id ]

    friend_ids = current_user.friends.ids rescue []
    unless others.all? { |uid| friend_ids.include?(uid) }
      return redirect_back fallback_location: new_group_path, alert: "フレンドのみチャットできます"
    end


    if others.any? { |uid| Block.connecting_block(current_user.id, uid).exists? }
      return redirect_back fallback_location: new_group_path, alert: "ブロック中の相手が含まれています"
    end


    if (gid = Group.id_for_exact_members(user_ids))
      redirect_to group_path(gid), notice: "グループに入室しました"
    else
      names = User.where(id: user_ids).pluck(:name)
      group_name = (names.size <= 2) ? names.join("、") : "#{names.first(2).join("、")}..."
      group = Group.create!(name: group_name)
      user_ids.each { |uid| GroupUser.create!(group_id: group.id, user_id: uid) }
      redirect_to group_path(group), notice: "グループを作成しました"
    end
  end
end
