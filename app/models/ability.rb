class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    if user.has_role?(:admin)
      # Admins can manage all profiles and everything else
      can :manage, :all
    elsif user.has_role?(:moderator)
      # Moderators can manage profiles, except those of admins
      can :manage, Profile do |profile|
        !profile.user.has_role?(:admin)
      end
      can :manage, [Post, Comment, Report]
      can :read, :all
    else
      # Writers and other users can manage their own profiles only
      can [:read, :update], Profile, user_id: user.id
    end
    can :view_saved_posts, User, id: user.id

    # Ensure moderators cannot access admin profiles
    if user.has_role?(:moderator)
      cannot :manage, Profile do |profile|
        profile.user.has_role?(:admin)
      end
    end

    # All users (including guests) can read public content
    can :read, Post do |post|
      post.published_post?
    end
    # Registered users can report posts, comments, and users, but not their own content
    if user.persisted?
      can :report, [Post, Comment, User] do |resource|
        resource.user_id != user.id
      end
    end

    # All registered users can update or destroy their own comments
    if user.persisted?
      can [:update, :destroy], Comment, user_id: user.id
    end
  end
end
