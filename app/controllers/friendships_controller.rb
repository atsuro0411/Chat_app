class FriendshipsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_friendship!, only: [ :destroy, :accept, :decline ]

  def create
    addressee_id = params[:addressee_id].to_i
    if Block.connecting_block(current_user.id, addressee_id).exists?
      return redirect_back fallback_location: friendships_path, alert: "ブロック中のため申請できません"
    end
    return redirect_back fallback_location: search_users_path, alert: "宛先が不正です" if addressee_id.zero?
    return redirect_back fallback_location: search_users_path, alert: "自分自身には申請できません" if addressee_id == current_user.id

    existing = Friendship.connecting(current_user.id, addressee_id).first

    if existing
      case existing.status
      when "accepted"
        redirect_back fallback_location: search_users_path, alert: "既にフレンドです"

      when "pending"
        if existing.requester_id == current_user.id
          redirect_back fallback_location: search_users_path, alert: "すでに申請中です"
        else
          redirect_back fallback_location: search_users_path, alert: "相手からの申請が来ています"
        end

      when "declined"
        if existing.requester_id == current_user.id
          existing.update!(status: :pending)
          redirect_back fallback_location: search_users_path, notice: "再申請しました"
        else
          create_new_request!(addressee_id)
        end
      end
    else
      create_new_request!(addressee_id)
    end
  end

  def destroy
    unless participant?(@friendship, current_user.id)
      return redirect_back fallback_location: search_users_path, alert: "権限がありません"
    end
    if @friendship.pending? && @friendship.requester_id == current_user.id
      @friendship.destroy!
      redirect_back fallback_location: search_users_path, notice: "申請を取り消しました"
    elsif @friendship.accepted?
      @friendship.destroy!
      redirect_back fallback_location: search_users_path, notice: "フレンドを解除しました"
    else
      redirect_back fallback_location: search_users_path, alert: "この申請は削除できません"
    end
  end

  def accept
    return redirect_back fallback_location: search_users_path, alert: "処理不可" unless @friendship.pending?
    return redirect_back fallback_location: search_users_path, alert: "受信者のみ操作できます" unless @friendship.addressee_id == current_user.id

    @friendship.accept!
    redirect_back fallback_location: search_users_path, notice: "フレンドになりました"
  end

  def decline
    return redirect_back fallback_location: search_users_path, alert: "処理不可" unless @friendship.pending?
    return redirect_back fallback_location: search_users_path, alert: "受信者のみ操作できます" unless @friendship.addressee_id == current_user.id

    @friendship.decline!
    redirect_back fallback_location: search_users_path, notice: "申請を拒否しました"
  end

  private

  def set_friendship!
    @friendship = Friendship.where(id: params[:id])
                            .where("requester_id = :me OR addressee_id = :me", me: current_user.id)
                            .first
    redirect_back fallback_location: search_users_path, alert: "対象の申請が見つかりません" and return unless @friendship
  end

  def create_new_request!(addressee_id)
    fr = current_user.sent_friendships.build(addressee_id: addressee_id)
    if fr.save
      redirect_back fallback_location: search_users_path, notice: "申請を送りました"
    else
      redirect_back fallback_location: search_users_path, alert: fr.errors.full_messages.to_sentence
    end
  end

  def participant?(fr, uid)
    fr.requester_id == uid || fr.addressee_id == uid
  end
end
