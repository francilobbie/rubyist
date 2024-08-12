class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:show, :posts]
  before_action :set_user, only: [:show, :posts]

  def show
    # You can add any additional logic for the user profile here
  end
  def edit

  end

  def update
    if current_user.update(user_params)
      redirect_to user_path(current_user)
    else
      render :edit
    end
  end

  def posts
    @draft_posts = @user.posts.draft.order(created_at: :desc)
    @published_posts = @user.posts.published.order(created_at: :desc)
    @scheduled_posts = @user.posts.scheduled.order(created_at: :desc)
    @all_posts = @user.posts.order(created_at: :desc)

    case params[:filter]
    when 'draft'
      @posts = @draft_posts
    when 'published'
      @posts = @published_posts
    when 'scheduled'
      @posts = @scheduled_posts
    else
      @posts = @all_posts
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
