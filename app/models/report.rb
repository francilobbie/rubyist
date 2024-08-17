class Report < ApplicationRecord
  belongs_to :user
  belongs_to :reportable, polymorphic: true

  enum status: { pending: 'pending', reviewed: 'reviewed', closed: 'closed' }
  validates :category, presence: true, inclusion: { in: ['spam', 'abuse', 'harassment', 'inappropriate content', 'other'] }
end
