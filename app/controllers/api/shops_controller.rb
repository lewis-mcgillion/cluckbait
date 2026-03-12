module Api
  class ShopsController < ApplicationController
    skip_before_action :verify_authenticity_token, only: :index

    def index
      shops = ChickenShop.left_joins(:reviews)
                         .select("chicken_shops.*, COALESCE(AVG(reviews.rating), 0) as avg_rating, COUNT(reviews.id) as review_count")
                         .group("chicken_shops.id")

      if params[:search].present?
        term = ActiveRecord::Base.sanitize_sql_like(params[:search])
        shops = shops.where("name LIKE ? OR city LIKE ? OR postcode LIKE ?",
          "%#{term}%", "%#{term}%", "%#{term}%")
      end

      if params[:lat].present? && params[:lng].present?
        lat = params[:lat].to_f
        lng = params[:lng].to_f

        errors = []
        errors << "lat must be between -90 and 90" unless lat.between?(-90, 90)
        errors << "lng must be between -180 and 180" unless lng.between?(-180, 180)

        if errors.any?
          return render json: { error: "Invalid coordinates: #{errors.join(', ')}" },
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
          average_rating: shop.avg_rating.to_f.round(1),
          reviews_count: shop.review_count,
          url: chicken_shop_path(shop)
        }
      }
    end
  end
end
