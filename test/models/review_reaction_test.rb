require "test_helper"

class ReviewReactionTest < ActiveSupport::TestCase
  # -- Associations --

  test "belongs to a user" do
    reaction = create(:review_reaction)
    assert_instance_of User, reaction.user
  end

  test "belongs to a review" do
    reaction = create(:review_reaction)
    assert_instance_of Review, reaction.review
  end

  # -- Validations --

  test "valid with all required attributes" do
    assert build(:review_reaction).valid?
  end

  test "invalid without kind" do
    reaction = build(:review_reaction, kind: nil)
    assert_not reaction.valid?
    assert reaction.errors[:kind].any?
  end

  test "invalid with unknown kind" do
    reaction = build(:review_reaction, kind: "clap")
    assert_not reaction.valid?
    assert reaction.errors[:kind].any?
  end

  test "valid with each allowed kind" do
    ReviewReaction::KINDS.each do |kind|
      reaction = build(:review_reaction, kind: kind)
      assert reaction.valid?, "Expected #{kind} to be valid"
    end
  end

  test "enforces uniqueness of kind per user per review" do
    user = create(:user)
    review = create(:review)
    create(:review_reaction, user: user, review: review, kind: "fire")

    duplicate = build(:review_reaction, user: user, review: review, kind: "fire")
    assert_not duplicate.valid?
    assert duplicate.errors[:kind].any?
  end

  test "same user can react with different kinds to the same review" do
    user = create(:user)
    review = create(:review)
    create(:review_reaction, user: user, review: review, kind: "fire")

    assert build(:review_reaction, user: user, review: review, kind: "thumbs_up").valid?
  end

  test "different users can react with the same kind to the same review" do
    review = create(:review)
    user1 = create(:user)
    user2 = create(:user)
    create(:review_reaction, user: user1, review: review, kind: "fire")

    assert build(:review_reaction, user: user2, review: review, kind: "fire").valid?
  end

  # -- Review.by_most_helpful --

  test "by_most_helpful orders reviews by helpful score descending" do
    shop = create(:chicken_shop)
    low = create(:review, chicken_shop: shop)
    high = create(:review, chicken_shop: shop)

    3.times { create(:review_reaction, review: high, kind: "helpful") }
    1.times { create(:review_reaction, review: low, kind: "helpful") }

    results = Review.by_most_helpful.to_a
    assert results.index(high) < results.index(low)
  end

  # -- Dependent destroy --

  test "reactions are destroyed when review is destroyed" do
    review = create(:review)
    create(:review_reaction, review: review, kind: "fire")
    create(:review_reaction, review: review, kind: "thumbs_up")

    assert_difference "ReviewReaction.count", -2 do
      review.destroy
    end
  end
end
