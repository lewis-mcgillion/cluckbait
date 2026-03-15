class PresenceChannel < ApplicationCable::Channel
  periodically :heartbeat, every: 30.seconds

  def subscribed
    stream_for current_user
    update_presence
    broadcast_status(online: true)
  end

  def unsubscribed
    broadcast_status(online: false)
  end

  private

  def heartbeat
    update_presence
  end

  def update_presence
    current_user.update_column(:last_seen_at, Time.current)
  end

  def broadcast_status(online:)
    current_user.friends.find_each do |friend|
      PresenceChannel.broadcast_to(friend, {
        type: "presence",
        user_id: current_user.id,
        online: online
      })
    end
  end
end
