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


  scope :draft, -> { where(published_at: nil)}
  scope :published, -> { where("published_at <= ?", Time.current) }
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

    def published?
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
end
