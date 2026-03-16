class BadgeEvaluator
  EVALUATORS = {
    "first_cluck" => :review_count,
    "wing_warrior" => :review_count,
    "bucket_lister" => :review_count,
    "colonel" => :review_count,
    "golden_drumstick" => :review_count,
    "shutterbug" => :photo_count,
    "helpful_hen" => :helpful_reaction_count,
    "social_butterfly" => :friend_count,
    "explorer" => :cities_explored_count,
    "wishlist_wizard" => :visited_wishlist_count
  }.freeze

  # Returns which badge keys are relevant to a given action category
  CATEGORY_BADGES = {
    "reviews" => %w[first_cluck wing_warrior bucket_lister colonel golden_drumstick explorer],
    "photos" => %w[shutterbug],
    "reactions" => %w[helpful_hen],
    "social" => %w[social_butterfly],
    "wishlist" => %w[wishlist_wizard]
  }.freeze

  def self.evaluate(user, categories: nil)
    new(user, categories: categories).evaluate
  end

  def self.progress(user, badge_key)
    new(user).progress(badge_key)
  end

  def initialize(user, categories: nil)
    @user = user
    @categories = categories
  end

  def evaluate
    badges_to_check.each do |badge|
      next if badge.earned_by?(@user)

      current_progress = progress(badge.key)
      if current_progress >= badge.threshold
        award(badge)
      end
    end
  end

  def progress(badge_key)
    method_name = EVALUATORS[badge_key]
    return 0 unless method_name

    send(method_name)
  end

  private

  def badges_to_check
    if @categories
      keys = @categories.flat_map { |cat| CATEGORY_BADGES[cat] || [] }
      Badge.where(key: keys)
    else
      Badge.all
    end
  end

  def award(badge)
    user_badge = @user.user_badges.create(badge: badge)
    return unless user_badge.persisted?

    Notification.create(
      user: @user,
      action: "badge_earned",
      notifiable: user_badge
    )

    Activity.create!(
      user: @user,
      action: "earned_badge",
      trackable: user_badge
    )
  end

  def review_count
    @review_count ||= @user.reviews.count
  end

  def photo_count
    @photo_count ||= ActiveStorage::Attachment.where(
      record_type: "Review",
      record_id: @user.reviews.select(:id),
      name: "photos"
    ).count
  end

  def helpful_reaction_count
    @helpful_reaction_count ||= ReviewReaction.where(
      review_id: @user.reviews.select(:id),
      kind: "helpful"
    ).count
  end

  def friend_count
    @friend_count ||= @user.friends.count
  end

  def cities_explored_count
    @cities_explored_count ||= ChickenShop.where(
      id: @user.reviews.select(:chicken_shop_id)
    ).distinct.count(:city)
  end

  def visited_wishlist_count
    @visited_wishlist_count ||= @user.wishlist_items.visited.count
  end
end
