module Admin
  class ShopsController < BaseController
    before_action :set_shop, only: [:show, :edit, :update, :destroy]

    PER_PAGE = 25

    def index
      @page = [(params[:page] || 1).to_i, 1].max
      @shops = ChickenShop.order(created_at: :desc)
      @shops = @shops.where("name LIKE ? OR city LIKE ?", "%#{params[:search]}%",
                                                          "%#{params[:search]}%") if params[:search].present?
      @shops = @shops.where(city: params[:city]) if params[:city].present?

      fetched = @shops.limit(PER_PAGE + 1).offset((@page - 1) * PER_PAGE).to_a
      @has_next_page = fetched.length > PER_PAGE
      @shops = @has_next_page ? fetched.first(PER_PAGE) : fetched
    end

    def show
      @reviews = @shop.reviews.includes(:user).order(created_at: :desc).limit(10)
    end

    def edit
    end

    def update
      if @shop.update(shop_params)
        audit!("shop.update", target: @shop, metadata: { changes: @shop.previous_changes.except("updated_at") })
        redirect_to admin_shop_path(@shop), notice: "Shop updated successfully."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      audit!("shop.destroy", target: @shop, metadata: { name: @shop.name })
      @shop.destroy!
      redirect_to admin_shops_path, notice: "Shop has been deleted."
    end

    private

    def set_shop
      @shop = ChickenShop.find(params[:id])
    end

    def shop_params
      params.require(:chicken_shop).permit(:name, :address, :city, :postcode, :phone,
                                           :website, :description, :latitude, :longitude)
    end
  end
end
