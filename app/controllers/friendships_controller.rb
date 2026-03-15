class FriendshipsController < ApplicationController
  before_action :authenticate_user!

  def index
    @friends = current_user.friends
    @pending_requests = current_user.pending_friend_requests.includes(:user)
    @sent_requests = current_user.sent_friendships.pending.includes(:friend)

    @page = [(params[:page] || 1).to_i, 1].max
    @per_page = 25
    fetched = @friends.limit(@per_page + 1).offset((@page - 1) * @per_page).to_a
    @has_next_page = fetched.length > @per_page
    @friends = @has_next_page ? fetched.first(@per_page) : fetched

    if @friends.any?
      friend_ids = @friends.map(&:id)
      @friendships_by_friend = Friendship.for_user(current_user)
                                         .where(user_id: friend_ids).or(Friendship.for_user(current_user).where(friend_id: friend_ids))
                                         .index_by { |f| f.other_user(current_user).id }
    end
  end

  def create
    friend = User.find(params[:friend_id])

    existing = current_user.friendship_with(friend)
    if existing
      redirect_to profile_path(friend), alert: "Friend request already exists."
      return
    end

    @friendship = Friendship.new(user: current_user, friend: friend, status: :pending)

    begin
      if @friendship.save
        redirect_to profile_path(friend), notice: "Friend request sent to #{friend.name}! 🤝"
      else
        redirect_to profile_path(friend), alert: "Unable to send friend request. Please try again."
      end
    rescue ActiveRecord::RecordNotUnique
      redirect_to profile_path(friend), alert: "Friend request already exists."
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

    # Remove all friendship records between both users (both directions)
    Friendship.where(user: current_user, friend: other)
              .or(Friendship.where(user: other, friend: current_user))
              .destroy_all

    # Also remove any conversation between the two users
    Conversation.between(current_user, other).destroy_all

    redirect_to friendships_path, notice: "Friendship with #{other.name} removed."
  end
end
