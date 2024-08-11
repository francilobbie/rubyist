# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    user ||= User.new # guest user (not logged in)

    if user.has_role? :admin
      # Admins can do anything
      can :manage, :all
    end

    if user.has_role? :moderator
      # Moderators can read anything and manage posts and comments (create, read, update, delete)
      # They can also manage reports (create, read, update, delete)
      can :read, :all
      can :manage, [Post, Comment, Report]
    end

    if user.has_role? :writer
      # Writers can read anything
      # They can create posts and comments
      # They can update and delete their own posts and comments
      can :read, :all
      can :create, [Post, Comment]
      can [:update, :destroy], [Post, Comment], user_id: user.id
    end

    # All users (including guests) can read all content
    can :read, :all

    # Registered users (including writers, and possibly others) can report Posts, Comments, and Users
    # The ability to report is restricted based on not being the owner of the content
    if user.persisted?
      can :report, [Post, Comment, User] do |resource|
        resource.user_id != user.id
      end
    end

    # Specific abilities for updating and destroying one's own comments,
    # useful for all registered users but defined outside the guest user block
    if user.persisted?
      can [:update, :destroy], Comment, user_id: user.id
    end

  end
end
