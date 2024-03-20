# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    if user.has_role? :admin
      can :manage, :all
      can :report, [Post, Comment, User]
    elsif user.has_role? :moderator
      can :read, :all
      can :update, Post
      can :manage, Comment
      can :report, [Post, Comment, User]
    elsif user.has_role? :writer
      can :read, :all
      can :create, Comment
      can :update, Comment, user_id: user.id
      can :destroy, Comment, user_id: user.id
      can :create, Post
      can :update, Post, user_id: user.id
      can :report, [Post, Comment] # Maybe writers can't report Users
    else
      can :read, :all
      can :create, Comment
      can :report, [Post, Comment] # Normal users can report posts and comments but not other users
    end
  end
end
