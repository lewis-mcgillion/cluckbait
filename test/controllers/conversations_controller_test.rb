require "test_helper"

class ConversationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @friend = create(:user)
    create(:friendship, :accepted, user: @user, friend: @friend)
    sign_in @user
  end

  test "index shows conversations" do
    conversation = create(:conversation, sender: @user, receiver: @friend)
    create(:message, conversation: conversation, user: @user, body: "Hello!")
    get conversations_path
    assert_response :success
  end

  test "show displays conversation" do
    conversation = create(:conversation, sender: @user, receiver: @friend)
    get conversation_path(conversation)
    assert_response :success
  end

  test "create finds or creates conversation" do
    assert_difference "Conversation.count", 1 do
      post conversations_path, params: { receiver_id: @friend.id }
    end
    assert_redirected_to conversation_path(Conversation.last)
  end

  test "create reuses existing conversation" do
    existing = create(:conversation, sender: @user, receiver: @friend)
    assert_no_difference "Conversation.count" do
      post conversations_path, params: { receiver_id: @friend.id }
    end
    assert_redirected_to conversation_path(existing)
  end

  test "cannot view conversation you're not part of" do
    other1 = create(:user)
    other2 = create(:user)
    create(:friendship, :accepted, user: other1, friend: other2)
    convo = create(:conversation, sender: other1, receiver: other2)
    get conversation_path(convo)
    assert_response :not_found
  end

  test "requires authentication" do
    sign_out @user
    get conversations_path
    assert_redirected_to new_user_session_path
  end
end
