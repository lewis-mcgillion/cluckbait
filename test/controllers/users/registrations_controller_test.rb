require "test_helper"

class Users::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  # -- Sign up --

  test "sign up with display_name creates user with display name" do
    assert_difference "User.count", 1 do
      post user_registration_path, params: {
        user: {
          email: "newuser@example.com",
          password: "password123",
          password_confirmation: "password123",
          display_name: "ChickenLover"
        }
      }
    end

    user = User.find_by(email: "newuser@example.com")
    assert_equal "ChickenLover", user.display_name
  end

  test "sign up without display_name creates user" do
    assert_difference "User.count", 1 do
      post user_registration_path, params: {
        user: {
          email: "noname@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end
    assert_redirected_to root_path
  end

  test "sign up with invalid email fails" do
    assert_no_difference "User.count" do
      post user_registration_path, params: {
        user: {
          email: "",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end
    assert_response :unprocessable_entity
  end

  test "sign up with mismatched passwords fails" do
    assert_no_difference "User.count" do
      post user_registration_path, params: {
        user: {
          email: "mismatch@example.com",
          password: "password123",
          password_confirmation: "different456"
        }
      }
    end
    assert_response :unprocessable_entity
  end

  test "sign up with duplicate email fails" do
    create(:user, email: "taken@example.com")

    assert_no_difference "User.count" do
      post user_registration_path, params: {
        user: {
          email: "taken@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end
    assert_response :unprocessable_entity
  end

  # -- Update without password --

  test "update profile without requiring current password" do
    user = create(:user, display_name: "OldName", bio: "Old bio")
    sign_in user

    put user_registration_path, params: {
      user: {
        display_name: "NewName",
        bio: "New bio"
      }
    }

    user.reload
    assert_equal "NewName", user.display_name
    assert_equal "New bio", user.bio
  end

  test "update email without requiring current password" do
    user = create(:user, email: "old@example.com")
    sign_in user

    put user_registration_path, params: {
      user: {
        email: "new@example.com"
      }
    }

    user.reload
    assert_equal "new@example.com", user.email
  end

  test "update with invalid display_name fails" do
    user = create(:user)
    sign_in user

    put user_registration_path, params: {
      user: {
        display_name: "a" * 51
      }
    }

    user.reload
    assert_not_equal "a" * 51, user.display_name
  end

  test "update requires authentication" do
    put user_registration_path, params: {
      user: { display_name: "Hacker" }
    }
    assert_redirected_to new_user_session_path
  end
end
