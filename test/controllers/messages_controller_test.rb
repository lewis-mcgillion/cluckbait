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
end
