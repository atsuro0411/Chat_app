module FriendshipsHelper
  def friendship_action_buttons(user, friendship: nil, show_chat: false)
    return "".html_safe if user.blank? || user == current_user


    if current_user.blocking?(user)

      return button_to("ブロック解除", unblock_path(user_id: user.id), method: :delete)
    elsif current_user.blocked_by?(user)

      return content_tag(:span, "ブロックされています")
    end

    pair = friendship || Friendship.connecting(current_user.id, user.id).first

    return button_to("フレンド申請",
                     friendships_path(addressee_id: user.id),
                     method: :post) if pair.nil?

    if pair.accepted?
      buttons = []
      buttons << button_to("チャットを開く",
                            groups_path(user_id: user.id),
                            method: :post,
                            form: { style: "display:inline" }) if show_chat
      buttons << button_to("フレンド解除",
                           friendship_path(pair),
                           method: :delete,
                           form: { data: { turbo_confirm: "本当に解除しますか？" } })

      buttons << button_to("ブロック", blocks_path(user_id: user.id), method: :post)
      return safe_join(buttons, " ")
    end

    if pair.pending?
      if pair.requester_id == current_user.id
        return safe_join([
          button_to("申請中（取り消す）", friendship_path(pair), method: :delete,
                    form: { data: { turbo_confirm: "申請を取り消しますか？" } }),
          button_to("ブロック", blocks_path(user_id: user.id), method: :post)
        ], " ")
      else
        return safe_join([
          button_to("承認",  accept_friendship_path(pair),  method: :patch),
          button_to("拒否",  decline_friendship_path(pair), method: :patch),
          button_to("ブロック", blocks_path(user_id: user.id), method: :post)
        ], " ")
      end
    end

    if pair.declined?
      return safe_join([
        button_to("再申請", friendships_path(addressee_id: user.id), method: :post),
        button_to("ブロック", blocks_path(user_id: user.id), method: :post)
      ], " ")
    end

    "".html_safe
  end
end
