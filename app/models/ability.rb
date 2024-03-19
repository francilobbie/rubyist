# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    if user.has_role? :admin
      can :manage, :all
    elsif user.has_role? :moderator
      can :read, :all
      can :update, Post
      can :manage, Comment # Moderators can manage all comments
    elsif user.has_role? :writer
      can :read, :all
      can :create, Comment # Writers can create comments
      can :update, Comment, user_id: user.id # Writers can update their own comments
      can :destroy, Comment, user_id: user.id # Writers can delete their own comments
      can :create, Post
      can :update, Post, user_id: user.id
    else
      can :update, Comment, user_id: user.id # Writers can update their own comments
      can :destroy, Comment, user_id: user.id # Writers can delete their own comments
      can :read, :all
      can :create, Comment # Normal users can create comments
    end
  end
end
