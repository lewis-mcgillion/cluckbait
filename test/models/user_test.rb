require "test_helper"

class UserTest < ActiveSupport::TestCase
  # -- Associations --

  test "has many reviews" do
    assert_respond_to build(:user), :reviews
  end

  test "destroying user destroys associated reviews" do
    user = create(:user)
    shop = create(:chicken_shop)
    create(:review, user: user, chicken_shop: shop)

    assert_difference "Review.count", -1 do
      user.destroy
    end
  end

  test "has one attached avatar" do
    assert_respond_to build(:user), :avatar
  end

  # -- Validations --

  test "valid with all required attributes" do
    assert build(:user).valid?
  end

  test "invalid without email" do
    user = build(:user, email: "")
    assert_not user.valid?
    assert user.errors[:email].any?
  end

  test "invalid without password" do
    user = build(:user, password: "")
    assert_not user.valid?
    assert user.errors[:password].any?
  end

  test "invalid with duplicate email" do
    create(:user, email: "taken@example.com")
    user = build(:user, email: "taken@example.com")
    assert_not user.valid?
    assert_includes user.errors[:email], "has already been taken"
  end

  test "display_name must be present" do
    assert_not build(:user, display_name: "").valid?
  end

  test "display_name cannot exceed 50 characters" do
    user = build(:user, :with_long_display_name)
    assert_not user.valid?
    assert user.errors[:display_name].any?
  end

  test "display_name at exactly 50 characters is valid" do
    assert build(:user, display_name: "a" * 50).valid?
  end

  test "bio can be blank" do
    assert build(:user, bio: "").valid?
  end

  test "bio cannot exceed 500 characters" do
    user = build(:user, :with_long_bio)
    assert_not user.valid?
    assert user.errors[:bio].any?
  end

  test "bio at exactly 500 characters is valid" do
    assert build(:user, bio: "a" * 500).valid?
  end

  # -- #name --

  test "name returns display_name when present" do
    user = build(:user, display_name: "Alice")
    assert_equal "Alice", user.name
  end

  test "name falls back to email prefix when display_name is blank" do
    user = build(:user, email: "carol@example.com", display_name: "")
    assert_equal "carol", user.name
  end

  test "name returns fallback when email prefix is empty" do
    user = build(:user, email: "@example.com", display_name: "")
    assert_equal "?", user.name
  end

  # -- #avatar_url --

  test "avatar_url returns nil when no avatar attached" do
    assert_nil build(:user).avatar_url
  end

  # -- #reviews_count --

  test "reviews_count returns the number of reviews" do
    user = create(:user)
    shop1 = create(:chicken_shop)
    shop2 = create(:chicken_shop)
    create(:review, user: user, chicken_shop: shop1)
    create(:review, user: user, chicken_shop: shop2)

    assert_equal 2, user.reviews_count
  end

  test "reviews_count returns 0 when no reviews" do
    assert_equal 0, create(:user).reviews_count
  end

  # -- #average_rating_given --

  test "average_rating_given calculates correctly" do
    user = create(:user)
    shop1 = create(:chicken_shop)
    shop2 = create(:chicken_shop)
    create(:review, user: user, chicken_shop: shop1, rating: 5)
    create(:review, user: user, chicken_shop: shop2, rating: 3)

    assert_equal 4.0, user.average_rating_given
  end

  test "average_rating_given returns nil when no reviews" do
    assert_nil create(:user).average_rating_given
  end

  # -- Friendship associations --

  test "has many sent_friendships" do
    assert_respond_to build(:user), :sent_friendships
  end

  test "has many received_friendships" do
    assert_respond_to build(:user), :received_friendships
  end

  test "sent friendships has dependent destroy configured" do
    reflection = User.reflect_on_association(:sent_friendships)
    assert_equal :destroy, reflection.options[:dependent]
  end

  test "destroying user destroys received friendships" do
    user = create(:user)
    friend = create(:user)
    create(:friendship, user: friend, friend: user)

    assert_difference "Friendship.count", -1 do
      user.destroy
    end
  end

  # -- Conversation associations --

  test "has many sent_conversations" do
    assert_respond_to build(:user), :sent_conversations
  end

  test "has many received_conversations" do
    assert_respond_to build(:user), :received_conversations
  end

  test "has many messages" do
    assert_respond_to build(:user), :messages
  end

  test "has many conversation_reads" do
    assert_respond_to build(:user), :conversation_reads
  end

  test "destroying user destroys sent conversations" do
    user = create(:user)
    friend = create(:user)
    create(:friendship, :accepted, user: user, friend: friend)
    create(:conversation, sender: user, receiver: friend)

    assert_difference "Conversation.count", -1 do
      user.destroy
    end
  end

  test "messages has dependent destroy configured" do
    reflection = User.reflect_on_association(:messages)
    assert_equal :destroy, reflection.options[:dependent]
  end

  test "destroying user destroys conversation reads" do
    user = create(:user)
    # Verify the dependent: :destroy configuration through reflection
    reflection = User.reflect_on_association(:conversation_reads)
    assert_equal :destroy, reflection.options[:dependent]
  end

  # -- #friends --

  test "friends returns accepted friends from both directions" do
    user = create(:user)
    friend1 = create(:user)
    friend2 = create(:user)
    pending_friend = create(:user)

    create(:friendship, :accepted, user: user, friend: friend1)
    create(:friendship, :accepted, user: friend2, friend: user)
    create(:friendship, user: user, friend: pending_friend)

    friends = user.friends
    assert_includes friends, friend1
    assert_includes friends, friend2
    assert_not_includes friends, pending_friend
  end

  test "friends returns empty when no accepted friendships" do
    user = create(:user)
    other = create(:user)
    create(:friendship, user: user, friend: other) # pending

    assert_empty user.friends
  end

  # -- #pending_friend_requests --

  test "pending_friend_requests returns pending requests received by user" do
    user = create(:user)
    requester = create(:user)
    create(:friendship, user: requester, friend: user, status: :pending)

    assert_equal 1, user.pending_friend_requests.count
  end

  test "pending_friend_requests excludes sent requests" do
    user = create(:user)
    other = create(:user)
    create(:friendship, user: user, friend: other, status: :pending)

    assert_equal 0, user.pending_friend_requests.count
  end

  # -- #pending_friend_requests_count --

  test "pending_friend_requests_count returns correct count" do
    user = create(:user)
    create(:friendship, user: create(:user), friend: user, status: :pending)
    create(:friendship, user: create(:user), friend: user, status: :pending)

    assert_equal 2, user.pending_friend_requests_count
  end

  test "pending_friend_requests_count returns 0 when none pending" do
    assert_equal 0, create(:user).pending_friend_requests_count
  end

  # -- #friendship_with --

  test "friendship_with finds friendship where user is sender" do
    user = create(:user)
    friend = create(:user)
    friendship = create(:friendship, user: user, friend: friend)

    assert_equal friendship, user.friendship_with(friend)
  end

  test "friendship_with finds friendship where user is receiver" do
    user = create(:user)
    friend = create(:user)
    friendship = create(:friendship, user: friend, friend: user)

    assert_equal friendship, user.friendship_with(friend)
  end

  test "friendship_with returns nil when no friendship exists" do
    user = create(:user)
    stranger = create(:user)

    assert_nil user.friendship_with(stranger)
  end

  # -- #friends_with? --

  test "friends_with? returns true for accepted friendship" do
    user = create(:user)
    friend = create(:user)
    create(:friendship, :accepted, user: user, friend: friend)

    assert user.friends_with?(friend)
  end

  test "friends_with? returns false for pending friendship" do
    user = create(:user)
    friend = create(:user)
    create(:friendship, user: user, friend: friend, status: :pending)

    assert_not user.friends_with?(friend)
  end

  test "friends_with? returns false when no friendship" do
    user = create(:user)
    stranger = create(:user)

    assert_not user.friends_with?(stranger)
  end

  # -- #conversations --

  test "conversations returns conversations where user is sender or receiver" do
    user = create(:user)
    friend1 = create(:user)
    friend2 = create(:user)
    create(:friendship, :accepted, user: user, friend: friend1)
    create(:friendship, :accepted, user: user, friend: friend2)
    create(:conversation, sender: user, receiver: friend1)
    create(:conversation, sender: friend2, receiver: user)

    assert_equal 2, user.conversations.count
  end

  test "conversations excludes conversations user is not part of" do
    user = create(:user)
    other1 = create(:user)
    other2 = create(:user)
    create(:friendship, :accepted, user: other1, friend: other2)
    create(:conversation, sender: other1, receiver: other2)

    assert_equal 0, user.conversations.count
  end

  # -- #unread_conversations_count --

  test "unread_conversations_count returns 0 with no messages" do
    user = create(:user)
    friend = create(:user)
    create(:friendship, :accepted, user: user, friend: friend)
    create(:conversation, sender: user, receiver: friend)

    assert_equal 0, user.unread_conversations_count
  end

  test "unread_conversations_count counts conversations with unread messages from others" do
    user = create(:user)
    friend = create(:user)
    create(:friendship, :accepted, user: user, friend: friend)
    conversation = create(:conversation, sender: user, receiver: friend)
    create(:message, conversation: conversation, user: friend, body: "Hello!")

    assert_equal 1, user.unread_conversations_count
  end

  test "unread_conversations_count ignores own messages" do
    user = create(:user)
    friend = create(:user)
    create(:friendship, :accepted, user: user, friend: friend)
    conversation = create(:conversation, sender: user, receiver: friend)
    create(:message, conversation: conversation, user: user, body: "Hello!")

    assert_equal 0, user.unread_conversations_count
  end

  # -- Missing association tests --

  test "has many activities" do
    assert_respond_to build(:user), :activities
  end

  test "destroying user destroys associated activities" do
    user = create(:user)
    shop = create(:chicken_shop)
    create(:review, user: user, chicken_shop: shop) # creates activity via callback

    assert Activity.where(user: user).any?
    assert_difference "Activity.count", -1 do
      user.destroy
    end
  end

  test "has many review_reactions" do
    assert_respond_to build(:user), :review_reactions
  end

  test "destroying user destroys associated review_reactions" do
    user = create(:user)
    review = create(:review)
    create(:review_reaction, user: user, review: review)

    assert_difference "ReviewReaction.count", -1 do
      user.destroy
    end
  end

  test "has many notifications" do
    assert_respond_to build(:user), :notifications
  end

  test "destroying user destroys associated notifications" do
    user = create(:user)
    create(:notification, user: user)

    assert_difference "Notification.count", -1 do
      user.destroy
    end
  end

  # -- acceptable_avatar validation --

  test "acceptable_avatar rejects non-image content types" do
    user = build(:user)
    user.avatar.attach(
      io: StringIO.new("not an image"),
      filename: "document.pdf",
      content_type: "application/pdf"
    )

    assert_not user.valid?
    assert user.errors[:avatar].any?
  end

  test "acceptable_avatar allows valid image types" do
    user = build(:user)
    user.avatar.attach(
      io: StringIO.new("fake image"),
      filename: "avatar.jpg",
      content_type: "image/jpeg"
    )

    assert user.valid?
  end

  test "acceptable_avatar allows png" do
    user = build(:user)
    user.avatar.attach(
      io: StringIO.new("fake png"),
      filename: "avatar.png",
      content_type: "image/png"
    )

    assert user.valid?
  end

  test "acceptable_avatar allows gif" do
    user = build(:user)
    user.avatar.attach(
      io: StringIO.new("fake gif"),
      filename: "avatar.gif",
      content_type: "image/gif"
    )

    assert user.valid?
  end

  test "acceptable_avatar allows webp" do
    user = build(:user)
    user.avatar.attach(
      io: StringIO.new("fake webp"),
      filename: "avatar.webp",
      content_type: "image/webp"
    )

    assert user.valid?
  end

  test "acceptable_avatar rejects files over 5MB" do
    user = build(:user)
    large_content = "a" * (6.megabytes)
    user.avatar.attach(
      io: StringIO.new(large_content),
      filename: "large.jpg",
      content_type: "image/jpeg"
    )

    assert_not user.valid?
    assert user.errors[:avatar].any?
  end

  test "user is valid without avatar" do
    user = build(:user)
    assert_not user.avatar.attached?
    assert user.valid?
  end

  # -- #unread_notifications_count --

  test "unread_notifications_count returns count of unread notifications" do
    user = create(:user)
    create(:notification, user: user)
    create(:notification, user: user)
    create(:notification, :read, user: user)

    assert_equal 2, user.unread_notifications_count
  end

  test "unread_notifications_count returns 0 when all are read" do
    user = create(:user)
    create(:notification, :read, user: user)

    assert_equal 0, user.unread_notifications_count
  end

  test "unread_notifications_count returns 0 when no notifications" do
    user = create(:user)
    assert_equal 0, user.unread_notifications_count
  end

  # -- .search_by_name_or_email --

  test "search_by_name_or_email matches display_name" do
    alice = create(:user, display_name: "Alice")
    create(:user, display_name: "Bob")

    results = User.search_by_name_or_email("Alice")
    assert_includes results, alice
    assert_equal 1, results.count
  end

  test "search_by_name_or_email matches email" do
    alice = create(:user, email: "alice@example.com")
    create(:user, email: "bob@example.com")

    results = User.search_by_name_or_email("alice@")
    assert_includes results, alice
    assert_equal 1, results.count
  end

  test "search_by_name_or_email is case-insensitive" do
    alice = create(:user, display_name: "Alice")
    results = User.search_by_name_or_email("alice")
    assert_includes results, alice
  end

  test "search_by_name_or_email matches partial strings" do
    alice = create(:user, display_name: "Alice")
    results = User.search_by_name_or_email("lic")
    assert_includes results, alice
  end

  test "search_by_name_or_email returns none for blank query" do
    create(:user)
    assert_empty User.search_by_name_or_email("")
    assert_empty User.search_by_name_or_email(nil)
  end

  test "search_by_name_or_email sanitizes SQL wildcards" do
    user = create(:user, display_name: "Test%User")
    create(:user, display_name: "TestXUser")

    results = User.search_by_name_or_email("t%u")
    assert_includes results, user
    assert_equal 1, results.count
  end
end
