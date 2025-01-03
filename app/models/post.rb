class Post < ApplicationRecord
  include ActionView::RecordIdentifier

  resourcify

  validates :title, :body, presence: true

  has_many :taggings, dependent: :destroy
  has_many :tags, through: :taggings, dependent: :destroy
  belongs_to :user
  has_rich_text :body
  has_many :comments, dependent: :destroy
  has_many :likes, as: :likeable, dependent: :destroy
  has_many :post_views, dependent: :destroy
  belongs_to :series, optional: true


  has_many :save_posts, dependent: :destroy
  has_many :saved_by_users, through: :save_posts, source: :user

  scope :draft, -> { where(published_at: nil)}
  scope :published_post, -> { where("published_at <= ?", Time.current) }
  scope :scheduled, -> { where("published_at > ?", Time.current) }

  include PgSearch::Model
  pg_search_scope :global_search,
    against: [:title, :body],
    associated_against: {
      tags: [:name]
    },
    using: {
      tsearch: { prefix: true }
    }

    def draft?
      published_at.nil?
    end

    def published_post?
      published_at? && published_at <= Time.current
    end

    def scheduled?
      published_at? && published_at > Time.current
    end

  def tag_list
    tags.map(&:name).join(", ")
  end

  def tag_list=(names)
    self.tags = names.split(",").map do |n|
      Tag.where(name: n.strip).first_or_create!
    end
  end

  def broadcast_update_with_permissions(user)
    ability = Ability.new(user)
    permissions = {
      can_edit_post: ability.can?(:update, self),
      can_destroy_post: ability.can?(:destroy, self),
      can_destroy_tag: ability.can?(:destroy, Tag),
      can_report_post: ability.can?(:report, self)
    }

    broadcast_replace_later_to(
      self,
      target: dom_id(self),
      partial: "posts/post",
      locals: permissions.merge(post: self)
    )
  end

  def reading_time
    words_per_minute = 200
    word_count = body.to_plain_text.split.size
    time = (word_count / words_per_minute.to_f).ceil
    [time, 1].max # Ensures at least 1 minute reading time
  end

end
