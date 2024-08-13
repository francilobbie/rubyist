class User < ApplicationRecord
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :reports
  has_many :likes, dependent: :destroy

  has_one :profile, dependent: :destroy
  after_commit :create_profile, on: [:create]

  delegate :first_name, :last_name, :bio, :location, :avatar, to: :profile, allow_nil: true


  def suspended?
    suspended || (suspended_until && suspended_until > Time.current)
  end

  def report_count
    # Assuming there's a reports table where reportable can be a Post or Comment
    Report.where(reportable_type: 'Post', reportable_id: posts.ids).or(Report.where(reportable_type: 'Comment', reportable_id: comments.ids)).count
  end

  private

  def create_profile
    Profile.create(user: self)
  end

end
