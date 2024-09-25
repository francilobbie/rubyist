class User < ApplicationRecord
  require 'open-uri'

  rolify
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
        #  :confirmable, :trackable, :lockable,
         :lockable,
         :omniauthable, omniauth_providers: %i[google_oauth2 facebook github]

  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :reports
  has_many :likes, dependent: :destroy
  has_many :save_posts, dependent: :destroy
  has_many :saved_posts, through: :save_posts, source: :post
  has_one :profile, dependent: :destroy
  has_many :post_views, dependent: :destroy
  has_many :donations, dependent: :destroy
  has_many :series, dependent: :destroy
  has_many :feedbacks, dependent: :destroy


  after_commit :create_profile, on: [:create]
  after_commit :set_default_username, on: [:create]

  has_many :mentions, dependent: :destroy

  before_save :update_mentions, if: :username_changed?

  accepts_nested_attributes_for :profile

  delegate :first_name, :last_name, :bio, :location, :avatar, to: :profile, allow_nil: true

  has_many :notifications, as: :recipient, dependent: :destroy, class_name: 'Notification'

  def self.from_omniauth(auth)
    user = where(provider: auth.provider, uid: auth.uid).first_or_initialize
    user.email = auth.info.email if user.email.blank?
    user.password = Devise.friendly_token[0, 20] if user.encrypted_password.blank?
    user.username = auth.info.name || auth.info.email.split('@').first if user.username.blank?

    # Assign profile details
    user.build_profile unless user.profile.present?

    if auth.info.name.present?
      name_parts = auth.info.name.split(" ")
      user.profile.first_name = name_parts.first
      user.profile.last_name = name_parts[1..].join(' ')
    end

    # Attach avatar using ActiveStorage
    if user.profile.avatar.blank? && auth.info.image.present?
      avatar_url = auth.info.image
      avatar_file = URI.open(avatar_url) # Open the remote URL
      user.profile.avatar.attach(io: avatar_file, filename: "avatar-#{user.username}.jpg")
    end

    is_new_user = user.new_record?

    if user.save
      # Send welcome email if the user is new
      UserMailer.welcome_email(user).deliver_now if is_new_user
    end

    user
  end


  def suspended?
    suspended || (suspended_until && suspended_until > Time.current)
  end

  def avatar_url
    if avatar.attached?
      Rails.application.routes.url_helpers.rails_blob_url(avatar, only_path: true)
    else
      "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80"
    end
  end

  def report_count
    Report.where(reportable_type: 'Post', reportable_id: posts.ids)
          .or(Report.where(reportable_type: 'Comment', reportable_id: comments.ids))
          .count
  end

  def full_name
    first_name = profile&.first_name&.capitalize || "First Name"
    last_name = profile&.last_name&.upcase || "LAST NAME"
    [first_name, last_name].compact.join(' ')
  end


  def comment_name
    "#{full_name} (@#{username})"
  end

  private

  def create_profile
    Profile.create(user: self)
  end

  def set_default_username
    base_username = email.split('@').first
    new_username = base_username
    counter = 1

    while User.exists?(username: new_username)
      new_username = "#{base_username}#{counter}"
      counter += 1
    end

    update(username: new_username)
  end

  def update_mentions
    Mention.where("content LIKE ?", "%@[#{username_was}](#{id})%").find_each do |mention|
      mention.update(content: mention.content.gsub("@[#{username_was}](#{id})", "@[#{username}](#{id})"))
    end
  end
end
