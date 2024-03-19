class Post < ApplicationRecord
  resourcify


  validates :title, :body, presence: true

  has_many :taggings, dependent: :destroy
  has_many :tags, through: :taggings, dependent: :destroy
  belongs_to :user
  has_rich_text :body
  has_many :comments, dependent: :destroy


  include PgSearch::Model
  pg_search_scope :global_search,
    against: [ :title, :body ],
    associated_against: {
      tags: [ :name ]
    },
    using: {
      tsearch: { prefix: true }
    }

  def tag_list
    tags.map(&:name).join(", ")
  end

  def tag_list=(names)
    self.tags = names.split(",").map do |n|
      Tag.where(name: n.strip).first_or_create!
    end
  end
end
