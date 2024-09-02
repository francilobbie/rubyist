class User < ApplicationRecord
  require 'open-uri'

  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
        :recoverable, :rememberable, :validatable,
        :omniauthable, omniauth_providers: %i[google_oauth2 facebook github]

        def self.from_omniauth(auth)
          where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
            user.email = auth.info.email
            user.password = Devise.friendly_token[0, 20]

            # Create or update the user's profile with the first and last name
            if auth.info.name.present?
              names = auth.info.name.split
              user.build_profile(first_name: names.first, last_name: names[1..-1].join(' '))
            else
              user.build_profile # Create an empty profile if no name is provided
            end

            user.avatar.attach(io: URI.open(auth.info.image || "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80"), filename: 'avatar.jpg')

          end
        end



  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :reports
  has_many :likes, dependent: :destroy

  has_many :save_posts, dependent: :destroy
  has_many :saved_posts, through: :save_posts, source: :post
  has_one :profile, dependent: :destroy
  after_commit :create_profile, on: [:create]
  accepts_nested_attributes_for :profile

  delegate :first_name, :last_name, :bio, :location, :avatar, to: :profile, allow_nil: true

  has_many :notifications, as: :recipient, dependent: :destroy, class_name: 'Notification'



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
    # Assuming there's a reports table where reportable can be a Post or Comment
    Report.where(reportable_type: 'Post', reportable_id: posts.ids).or(Report.where(reportable_type: 'Comment', reportable_id: comments.ids)).count
  end

  def full_name
    [profile&.first_name, profile&.last_name].compact.join(' ')
  end

  private

  def create_profile
    Profile.create(user: self)
  end

end
