require "test_helper"

class SocialAccountTest < ActiveSupport::TestCase
  test "valid social account" do
    social_account = build(:social_account)
    assert social_account.valid?
  end

  test "requires provider" do
    social_account = build(:social_account, provider: nil)
    assert_not social_account.valid?
    assert_includes social_account.errors[:provider], "can't be blank"
  end

  test "requires uid" do
    social_account = build(:social_account, uid: nil)
    assert_not social_account.valid?
    assert_includes social_account.errors[:uid], "can't be blank"
  end

  test "requires user" do
    social_account = build(:social_account, user: nil)
    assert_not social_account.valid?
  end

  test "provider must be valid" do
    social_account = build(:social_account, provider: "invalid_provider")
    assert_not social_account.valid?
    assert_includes social_account.errors[:provider], "is not included in the list"
  end

  test "uid must be unique per provider" do
    existing = create(:social_account, provider: "google_oauth2", uid: "unique-123")
    duplicate = build(:social_account, provider: "google_oauth2", uid: "unique-123")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:uid], "has already been taken"
  end

  test "one provider per user" do
    user = create(:user)
    create(:social_account, user: user, provider: "google_oauth2")
    duplicate = build(:social_account, user: user, provider: "google_oauth2")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:provider], "is already linked to your account"
  end

  test "display_provider returns human-readable name" do
    assert_equal "Google", build(:social_account, :google).display_provider
  end

  test "same uid allowed for different providers" do
    create(:social_account, provider: "google_oauth2", uid: "shared-uid")
    other = build(:social_account, provider: "google_oauth2", uid: "shared-uid", user: create(:user))
    assert_not other.valid?
  end

  test "destroying user destroys social accounts" do
    user = create(:user)
    create(:social_account, user: user)
    assert_difference "SocialAccount.count", -1 do
      user.destroy
    end
  end
end
