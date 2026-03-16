require "test_helper"

class Users::OmniauthCallbacksControllerTest < ActionDispatch::IntegrationTest
  setup do
    OmniAuth.config.test_mode = true
  end

  teardown do
    OmniAuth.config.mock_auth[:google_oauth2] = nil
  end

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

  test "signed-in user can link google account" do
    user = create(:user)
    sign_in user
    mock_google_auth(email: user.email, uid: "new-google-uid")

    assert_difference "SocialAccount.count", 1 do
      post user_google_oauth2_omniauth_callback_path
    end

    assert user.social_accounts.exists?(provider: "google_oauth2")
    assert_redirected_to edit_user_registration_path
  end

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

  def mock_provider_auth(provider, email:, name: "Test User", uid: "#{provider}-#{SecureRandom.hex(8)}")
    OmniAuth.config.mock_auth[provider] = OmniAuth::AuthHash.new(
      provider: provider.to_s,
      uid: uid,
      info: { email: email, name: name, first_name: name.split.first, image: nil },
      credentials: { token: "mock-token", expires_at: 1.hour.from_now.to_i }
    )
  end
end
