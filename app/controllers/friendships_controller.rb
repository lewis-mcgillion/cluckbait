class FriendshipsController < ApplicationController
  before_action :authenticate_user!

  def index
    @friends = current_user.friends
    @pending_requests = current_user.pending_friend_requests.includes(:user)
    @sent_requests = current_user.sent_friendships.pending.includes(:friend)
  end

  def create
    friend = User.find(params[:friend_id])

    existing = current_user.friendship_with(friend)
    if existing
      redirect_to profile_path(friend), alert: "Friend request already exists."
      return
    end

    @friendship = Friendship.new(user: current_user, friend: friend, status: :pending)

    if @friendship.save
      redirect_to profile_path(friend), notice: "Friend request sent to #{friend.name}! 🤝"
    else
      redirect_to profile_path(friend), alert: @friendship.errors.full_messages.join(", ")
    end
  end

  def update
    @friendship = Friendship.pending_for(current_user).find(params[:id])
    @friendship.accepted!
    redirect_to friendships_path, notice: "You are now friends with #{@friendship.user.name}! 🎉"
  end

  def destroy
    @friendship = Friendship.for_user(current_user).find(params[:id])
    other = @friendship.other_user(current_user)
    @friendship.destroy

    # Also remove any conversation between the two users
    Conversation.between(current_user, other).destroy_all

    redirect_to friendships_path, notice: "Friendship with #{other.name} removed."
  end
end
