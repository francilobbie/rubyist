class User < ApplicationRecord
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :reports

  def suspended?
    suspended || (suspended_until && suspended_until > Time.current)
  end

  def report_count
    # Assuming there's a reports table where reportable can be a Post or Comment
    Report.where(reportable_type: 'Post', reportable_id: posts.ids).or(Report.where(reportable_type: 'Comment', reportable_id: comments.ids)).count
  end

end
