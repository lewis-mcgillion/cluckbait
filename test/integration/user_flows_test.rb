require "test_helper"

class UserFlowsTest < ActionDispatch::IntegrationTest
  test "visitor can browse home page" do
    get root_path
    assert_response :success
  end

  test "visitor can browse chicken shops index" do
    create(:chicken_shop, name: "Test Cluckers")
    get chicken_shops_path
    assert_response :success
  end

  test "visitor can view a chicken shop" do
    shop = create(:chicken_shop, name: "Cluck Palace")
    get chicken_shop_path(shop)
    assert_response :success
  end

  test "visitor can view a user profile" do
    user = create(:user, display_name: "ChickenFan")
    get profile_path(user)
    assert_response :success
  end

  test "visitor cannot create a review" do
    shop = create(:chicken_shop)
    post chicken_shop_reviews_path(shop), params: {
      review: { rating: 5, title: "Great", body: "Loved it" }
    }
    assert_redirected_to new_user_session_path
  end

  test "user can sign up" do
    assert_difference "User.count", 1 do
      post user_registration_path, params: {
        user: {
          email: "newuser@example.com",
          password: "password123",
          password_confirmation: "password123",
          display_name: "NewCluckFan"
        }
      }
    end
    assert_redirected_to root_path
  end

  test "user can sign in and create a review" do
    user = create(:user)
    shop = create(:chicken_shop)

    sign_in user

    assert_difference "Review.count", 1 do
      post chicken_shop_reviews_path(shop), params: {
        review: { rating: 5, title: "Top notch", body: "Best burger in town" }
      }
    end
  end

  test "user can sign in and delete their own review" do
    user = create(:user)
    shop = create(:chicken_shop)
    review = create(:review, user: user, chicken_shop: shop)

    sign_in user

    assert_difference "Review.count", -1 do
      delete chicken_shop_review_path(shop, review)
    end
  end

  test "user can update their profile" do
    user = create(:user, display_name: "OldName")
    sign_in user

    patch profile_path(user), params: {
      user: { display_name: "NewName", bio: "Updated bio" }
    }

    assert_redirected_to profile_path(user)
    user.reload
    assert_equal "NewName", user.display_name
  end

  test "full flow: sign up, find shop, leave review" do
    shop = create(:chicken_shop, name: "Golden Cluck")

    # Sign up
    post user_registration_path, params: {
      user: {
        email: "flowtest@example.com",
        password: "password123",
        password_confirmation: "password123"
      }
    }
    assert_redirected_to root_path
    follow_redirect!

    # Browse shops
    get chicken_shops_path
    assert_response :success

    # View shop
    get chicken_shop_path(shop)
    assert_response :success

    # Leave review
    assert_difference "Review.count", 1 do
      post chicken_shop_reviews_path(shop), params: {
        review: { rating: 5, title: "Perfect", body: "Absolutely fantastic burger" }
      }
    end
  end

  # -- Friendship and Messaging Flow --

  test "full flow: send friend request, accept, start conversation, exchange messages" do
    user1 = create(:user, display_name: "Alice")
    user2 = create(:user, display_name: "Bob")

    # User1 sends friend request to User2
    sign_in user1
    post friendships_path, params: { friend_id: user2.id }
    assert_redirected_to profile_path(user2)
    friendship = Friendship.last
    assert friendship.pending?

    # User2 accepts the friend request
    sign_out user1
    sign_in user2
    patch friendship_path(friendship)
    assert friendship.reload.accepted?

    # User2 starts a conversation with User1
    post conversations_path, params: { receiver_id: user1.id }
    conversation = Conversation.last
    assert_redirected_to conversation_path(conversation)

    # User2 sends a message
    post conversation_messages_path(conversation), params: {
      message: { body: "Hey Alice, found any good chicken spots?" }
    }
    assert_redirected_to conversation_path(conversation)

    # User1 reads and replies
    sign_out user2
    sign_in user1
    get conversation_path(conversation)
    assert_response :success

    post conversation_messages_path(conversation), params: {
      message: { body: "Yes! Check out this place!" }
    }
    assert_redirected_to conversation_path(conversation)

    assert_equal 2, conversation.messages.count
  end

  test "full flow: send friend request, accept, share chicken shop in message" do
    user1 = create(:user)
    user2 = create(:user)
    shop = create(:chicken_shop, name: "Best Cluckers")

    # Establish friendship
    create(:friendship, :accepted, user: user1, friend: user2)

    sign_in user1

    # Start conversation
    post conversations_path, params: { receiver_id: user2.id }
    conversation = Conversation.last

    # Share a chicken shop
    post conversation_messages_path(conversation), params: {
      message: { body: "Check this out!", shareable_type: "ChickenShop", shareable_id: shop.id }
    }

    message = Message.last
    assert_equal shop, message.shareable
    assert_equal "Check this out!", message.body
  end

  test "cannot message non-friends" do
    user1 = create(:user)
    user2 = create(:user)

    sign_in user1
    post conversations_path, params: { receiver_id: user2.id }
    assert_redirected_to friendships_path
    assert_equal "You can only message friends.", flash[:alert]
  end

  test "removing friendship removes conversation" do
    user1 = create(:user)
    user2 = create(:user)
    friendship = create(:friendship, :accepted, user: user1, friend: user2)
    create(:conversation, sender: user1, receiver: user2)

    sign_in user1
    assert_difference "Conversation.count", -1 do
      delete friendship_path(friendship)
    end
  end
end
