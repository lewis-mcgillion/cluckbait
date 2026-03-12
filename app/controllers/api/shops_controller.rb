module Api
  class ShopsController < ApplicationController
    protect_from_forgery with: :null_session

    def index
      shops = ChickenShop.all

      if params[:search].present?
        shops = shops.where("name LIKE ? OR city LIKE ? OR postcode LIKE ?",
          "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%")
      end

      if params[:lat].present? && params[:lng].present?
        lat = params[:lat].to_f
        lng = params[:lng].to_f

        unless lat.between?(-90, 90) && lng.between?(-180, 180)
          return render json: { error: "Invalid coordinates: lat must be between -90 and 90, lng must be between -180 and 180" },
                        status: :unprocessable_entity
        end

        # Simple distance filter (~30 miles)
        shops = shops.where(
          "latitude BETWEEN ? AND ? AND longitude BETWEEN ? AND ?",
          lat - 0.5, lat + 0.5, lng - 0.8, lng + 0.8
        )
      end

      render json: shops.map { |shop|
        {
          id: shop.id,
          name: shop.name,
          address: shop.full_address,
          city: shop.city,
          postcode: shop.postcode,
          latitude: shop.latitude,
          longitude: shop.longitude,
          average_rating: shop.average_rating,
          reviews_count: shop.reviews_count,
          url: chicken_shop_path(shop)
        }
      }
    end
  end
end
