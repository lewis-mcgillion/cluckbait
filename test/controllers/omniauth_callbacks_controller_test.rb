require "test_helper"

class Users::OmniauthCallbacksControllerTest < ActionDispatch::IntegrationTest
  setup do
    OmniAuth.config.test_mode = true
  end

  teardown do
    OmniAuth.config.mock_auth[:google_oauth2] = nil
    OmniAuth.config.mock_auth[:apple] = nil
    OmniAuth.config.mock_auth[:facebook] = nil
  end

  # --- Google OAuth2 ---

  test "google oauth creates new user when no account exists" do
    mock_google_auth(email: "newuser@gmail.com", name: "New User")

    assert_difference ["User.count", "SocialAccount.count"], 1 do
      post user_google_oauth2_omniauth_callback_path
    end

    user = User.find_by(email: "newuser@gmail.com")
    assert user.present?
    assert_equal "New User", user.display_name
    assert user.social_accounts.exists?(provider: "google_oauth2")
    assert_redirected_to root_path
  end

  test "google oauth signs in existing social account user" do
    user = create(:user, email: "existing@gmail.com")
    create(:social_account, :google, user: user, uid: "google-uid-123")
    mock_google_auth(email: "existing@gmail.com", uid: "google-uid-123")

    assert_no_difference ["User.count", "SocialAccount.count"] do
      post user_google_oauth2_omniauth_callback_path
    end

    assert_redirected_to root_path
  end

  test "google oauth links to existing user with same email" do
    user = create(:user, email: "linked@gmail.com")
    mock_google_auth(email: "linked@gmail.com", name: "Linked User")

    assert_no_difference "User.count" do
      assert_difference "SocialAccount.count", 1 do
        post user_google_oauth2_omniauth_callback_path
      end
    end

    assert user.social_accounts.exists?(provider: "google_oauth2")
    assert_redirected_to root_path
  end

  # --- Apple ---

  test "apple oauth creates new user" do
    mock_apple_auth(email: "apple@icloud.com", name: "Apple User")

    assert_difference ["User.count", "SocialAccount.count"], 1 do
      post user_apple_omniauth_callback_path
    end

    user = User.find_by(email: "apple@icloud.com")
    assert user.present?
    assert user.social_accounts.exists?(provider: "apple")
    assert_redirected_to root_path
  end

  # --- Facebook ---

  test "facebook oauth creates new user" do
    mock_facebook_auth(email: "fbuser@example.com", name: "FB User")

    assert_difference ["User.count", "SocialAccount.count"], 1 do
      post user_facebook_omniauth_callback_path
    end

    user = User.find_by(email: "fbuser@example.com")
    assert user.present?
    assert user.social_accounts.exists?(provider: "facebook")
    assert_redirected_to root_path
  end

  # --- Account linking (signed-in user) ---

  test "signed-in user can link a new social provider" do
    user = create(:user)
    sign_in user
    mock_google_auth(email: user.email, uid: "new-google-uid")

    assert_difference "SocialAccount.count", 1 do
      post user_google_oauth2_omniauth_callback_path
    end

    assert user.social_accounts.exists?(provider: "google_oauth2")
    assert_redirected_to edit_user_registration_path
  end

  # --- Failure ---

  test "oauth failure redirects to sign in with alert" do
    OmniAuth.config.mock_auth[:google_oauth2] = :invalid_credentials

    post user_google_oauth2_omniauth_callback_path
    assert_redirected_to new_user_session_path
  end

  private

  def mock_google_auth(email:, name: "Test User", uid: "google-#{SecureRandom.hex(8)}")
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid: uid,
      info: { email: email, name: name, image: nil },
      credentials: { token: "mock-token", refresh_token: "mock-refresh", expires_at: 1.hour.from_now.to_i }
    )
  end

  def mock_apple_auth(email:, name: "Test User", uid: "apple-#{SecureRandom.hex(8)}")
    OmniAuth.config.mock_auth[:apple] = OmniAuth::AuthHash.new(
      provider: "apple",
      uid: uid,
      info: { email: email, name: name, first_name: name.split.first, image: nil },
      credentials: { token: "mock-token", expires_at: 1.hour.from_now.to_i }
    )
  end

  def mock_facebook_auth(email:, name: "Test User", uid: "fb-#{SecureRandom.hex(8)}")
    OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new(
      provider: "facebook",
      uid: uid,
      info: { email: email, name: name, image: nil },
      credentials: { token: "mock-token", expires_at: 1.hour.from_now.to_i }
    )
  end
end
