require "test_helper"

class Admin::ShopsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:user, :admin)
    @user = create(:user)
    @shop = create(:chicken_shop, name: "Cluck Palace", city: "London")
  end

  # -- Authorization --

  test "non-admin cannot access shops" do
    sign_in @user
    get admin_shops_path
    assert_redirected_to root_path
  end

  # -- Index --

  test "admin can view shops index" do
    sign_in @admin
    get admin_shops_path
    assert_response :success
  end

  test "admin can search shops" do
    sign_in @admin
    get admin_shops_path, params: { search: "Cluck" }
    assert_response :success
  end

  # -- Show --

  test "admin can view shop details" do
    sign_in @admin
    get admin_shop_path(@shop)
    assert_response :success
  end

  # -- Edit --

  test "admin can view shop edit form" do
    sign_in @admin
    get edit_admin_shop_path(@shop)
    assert_response :success
  end

  # -- Update --

  test "admin can update a shop" do
    sign_in @admin
    patch admin_shop_path(@shop), params: { chicken_shop: { name: "New Name" } }
    assert_redirected_to admin_shop_path(@shop)
    assert_equal "New Name", @shop.reload.name
  end

  test "updating a shop creates an audit log" do
    sign_in @admin
    assert_difference "AdminAuditLog.count", 1 do
      patch admin_shop_path(@shop), params: { chicken_shop: { name: "Updated" } }
    end
    assert_equal "shop.update", AdminAuditLog.last.action
  end

  test "update with invalid data re-renders edit" do
    sign_in @admin
    patch admin_shop_path(@shop), params: { chicken_shop: { name: "" } }
    assert_response :unprocessable_entity
  end

  # -- Destroy --

  test "admin can delete a shop" do
    sign_in @admin
    assert_difference "ChickenShop.count", -1 do
      delete admin_shop_path(@shop)
    end
    assert_redirected_to admin_shops_path
  end

  test "deleting a shop creates an audit log" do
    sign_in @admin
    assert_difference "AdminAuditLog.count", 1 do
      delete admin_shop_path(@shop)
    end
    log = AdminAuditLog.last
    assert_equal "shop.destroy", log.action
    assert_equal "Cluck Palace", log.parsed_metadata["name"]
  end

  # -- Pagination --

  test "shops index supports pagination" do
    sign_in @admin
    get admin_shops_path, params: { page: 2 }
    assert_response :success
  end
end
