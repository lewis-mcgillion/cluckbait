require "test_helper"

class MessagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @friend = create(:user)
    create(:friendship, :accepted, user: @user, friend: @friend)
    @conversation = create(:conversation, sender: @user, receiver: @friend)
    sign_in @user
  end

  test "create adds message to conversation" do
    assert_difference "Message.count", 1 do
      post conversation_messages_path(@conversation), params: {
        message: { body: "Check this out!" }
      }, as: :turbo_stream
    end
    assert_response :success
  end

  test "create with shareable shop" do
    shop = create(:chicken_shop)
    assert_difference "Message.count", 1 do
      post conversation_messages_path(@conversation), params: {
        message: { body: "Try this!", shareable_type: "ChickenShop", shareable_id: shop.id }
      }, as: :turbo_stream
    end
    assert_equal shop, Message.last.shareable
  end

  test "cannot post to conversation you're not part of" do
    other1 = create(:user)
    other2 = create(:user)
    create(:friendship, :accepted, user: other1, friend: other2)
    other_convo = create(:conversation, sender: other1, receiver: other2)

    post conversation_messages_path(other_convo), params: {
      message: { body: "Sneaky!" }
    }
    assert_response :not_found
  end

  test "requires authentication" do
    sign_out @user
    post conversation_messages_path(@conversation), params: {
      message: { body: "Hello" }
    }
    assert_redirected_to new_user_session_path
  end

  test "create with invalid params renders error" do
    post conversation_messages_path(@conversation), params: {
      message: { body: "" }
    }
    assert_response :unprocessable_entity
  end

  test "create with html format redirects on success" do
    post conversation_messages_path(@conversation), params: {
      message: { body: "Hello from HTML!" }
    }
    assert_redirected_to conversation_path(@conversation)
  end

  test "create with shareable and no body fails" do
    shop = create(:chicken_shop)
    assert_no_difference "Message.count" do
      post conversation_messages_path(@conversation), params: {
        message: { body: "", shareable_type: "ChickenShop", shareable_id: shop.id }
      }, as: :turbo_stream
    end
  end

  test "create does not allow message with body over 2000 characters" do
    post conversation_messages_path(@conversation), params: {
      message: { body: "a" * 2001 }
    }
    assert_response :unprocessable_entity
  end

  test "create ignores disallowed shareable types" do
    assert_difference "Message.count", 1 do
      post conversation_messages_path(@conversation), params: {
        message: { body: "Trying injection", shareable_type: "User", shareable_id: @user.id }
      }, as: :turbo_stream
    end
    assert_nil Message.last.shareable
  end

  test "create ignores arbitrary class names as shareable type" do
    assert_difference "Message.count", 1 do
      post conversation_messages_path(@conversation), params: {
        message: { body: "Trying injection", shareable_type: "Kernel", shareable_id: 1 }
      }, as: :turbo_stream
    end
    assert_nil Message.last.shareable
  end

  test "create with shareable review" do
    shop = create(:chicken_shop)
    review = create(:review, user: @friend, chicken_shop: shop)
    assert_difference "Message.count", 1 do
      post conversation_messages_path(@conversation), params: {
        message: { body: "Look at this review!", shareable_type: "Review", shareable_id: review.id }
      }, as: :turbo_stream
    end
    assert_equal review, Message.last.shareable
  end

  test "create with non-existent shareable clears shareable" do
    assert_difference "Message.count", 1 do
      post conversation_messages_path(@conversation), params: {
        message: { body: "Check this!", shareable_type: "ChickenShop", shareable_id: 999999 }
      }, as: :turbo_stream
    end
    assert_nil Message.last.shareable
  end

  test "create with non-existent review shareable clears shareable" do
    assert_difference "Message.count", 1 do
      post conversation_messages_path(@conversation), params: {
        message: { body: "Check this!", shareable_type: "Review", shareable_id: 999999 }
      }, as: :turbo_stream
    end
    assert_nil Message.last.shareable
  end

  test "message body at exactly 2000 characters succeeds" do
    assert_difference "Message.count", 1 do
      post conversation_messages_path(@conversation), params: {
        message: { body: "a" * 2000 }
      }, as: :turbo_stream
    end
    assert_response :success
  end
end
