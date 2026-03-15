class WishlistItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_wishlist_item, only: [:update, :destroy]

  def index
    @filter = params[:filter] || "all"
    @wishlist_items = current_user.wishlist_items.includes(:chicken_shop).recent
    @wishlist_items = case @filter
    when "want_to_try" then @wishlist_items.want_to_try
    when "visited" then @wishlist_items.visited
    else @wishlist_items
    end

    @page = [(params[:page] || 1).to_i, 1].max
    @per_page = 25
    fetched = @wishlist_items.limit(@per_page + 1).offset((@page - 1) * @per_page).to_a
    @has_next_page = fetched.length > @per_page
    @wishlist_items = @has_next_page ? fetched.first(@per_page) : fetched
  end

  def create
    @chicken_shop = ChickenShop.find(params[:chicken_shop_id])
    @wishlist_item = current_user.wishlist_items.build(chicken_shop: @chicken_shop, visited: false,
notes: wishlist_params[:notes])

    if @wishlist_item.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @chicken_shop, notice: "Added to your wishlist! 🔖" }
      end
    else
      respond_to do |format|
        format.turbo_stream { head :unprocessable_entity }
        format.html { redirect_to @chicken_shop, alert: @wishlist_item.errors.full_messages.join(", ") }
      end
    end
  end

  def update
    @chicken_shop = @wishlist_item.chicken_shop

    if @wishlist_item.update(visited: !@wishlist_item.visited)
      respond_to do |format|
        format.turbo_stream
        format.html {
          redirect_to wishlist_items_path,
         notice: @wishlist_item.visited? ? "Marked as visited! ✅" : "Moved back to Want to Try"
        }
      end
    else
      respond_to do |format|
        format.turbo_stream { head :unprocessable_entity }
        format.html { redirect_to wishlist_items_path, alert: @wishlist_item.errors.full_messages.join(", ") }
      end
    end
  end

  def destroy
    @chicken_shop = @wishlist_item.chicken_shop

    if @wishlist_item.destroy
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to wishlist_items_path, notice: "Removed from wishlist." }
      end
    else
      respond_to do |format|
        format.turbo_stream { head :unprocessable_entity }
        format.html { redirect_to wishlist_items_path, alert: "Could not remove item from wishlist." }
      end
    end
  end

  private

  def set_wishlist_item
    @wishlist_item = current_user.wishlist_items.find(params[:id])
  end

  def wishlist_params
    params.permit(:notes)
  end
end
