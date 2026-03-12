require "test_helper"

class ReviewReactionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @review = create(:review)
  end

  # -- Authentication --

  test "create redirects unauthenticated users" do
    post review_reactions_path(@review), params: { kind: "fire" }
    assert_redirected_to new_user_session_path
  end

  # -- #create (toggle) --

  test "create adds a reaction when none exists" do
    sign_in @user

    assert_difference "ReviewReaction.count", 1 do
      post review_reactions_path(@review), params: { kind: "fire" }
    end

    reaction = ReviewReaction.last
    assert_equal @user, reaction.user
    assert_equal @review, reaction.review
    assert_equal "fire", reaction.kind
  end

  test "create removes a reaction when one exists (toggle off)" do
    sign_in @user
    create(:review_reaction, user: @user, review: @review, kind: "fire")

    assert_difference "ReviewReaction.count", -1 do
      post review_reactions_path(@review), params: { kind: "fire" }
    end
  end

  test "create responds with turbo_stream" do
    sign_in @user

    post review_reactions_path(@review), params: { kind: "thumbs_up" }, as: :turbo_stream

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html; charset=utf-8", response.content_type
  end

  test "create with html format redirects" do
    sign_in @user

    post review_reactions_path(@review), params: { kind: "thumbs_up" }

    assert_response :redirect
  end

  test "create with invalid kind returns error" do
    sign_in @user

    assert_no_difference "ReviewReaction.count" do
      post review_reactions_path(@review), params: { kind: "invalid" }
    end
    assert_response :unprocessable_entity
  end

  test "toggling different kinds creates separate reactions" do
    sign_in @user

    post review_reactions_path(@review), params: { kind: "fire" }
    post review_reactions_path(@review), params: { kind: "thumbs_up" }

    assert_equal 2, @review.reactions.where(user: @user).count
  end

  test "toggling helpful and not_helpful are independent" do
    sign_in @user

    post review_reactions_path(@review), params: { kind: "helpful" }
    post review_reactions_path(@review), params: { kind: "not_helpful" }

    assert_equal 2, @review.reactions.where(user: @user).count
  end
end
