module Api
  class ShopsController < ApplicationController
    protect_from_forgery with: :null_session

    def index
      shops = ChickenShop.left_joins(:reviews)
                         .select("chicken_shops.*, COALESCE(AVG(reviews.rating), 0) as avg_rating, COUNT(reviews.id) as review_count")
                         .group("chicken_shops.id")

      if params[:search].present?
        shops = shops.where("name LIKE ? OR city LIKE ? OR postcode LIKE ?",
          "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%")
      end

      if params[:lat].present? && params[:lng].present?
        lat = params[:lat].to_f
        lng = params[:lng].to_f
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
          average_rating: shop.avg_rating.to_f.round(1),
          reviews_count: shop.review_count,
          url: chicken_shop_path(shop)
        }
      }
    end
  end
end
