class PostsController < ApplicationController
  load_and_authorize_resource

  before_action :set_post, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]


  def index
    base_query = params[:query].present? ? Post.global_search(params[:query]) : Post.all

    all_posts = base_query.includes(:user).to_a

    @posts = all_posts.select do |post|
      !post.user.suspended? || (post.user.suspended? && post.user.suspended_until.present? && post.user.suspended_until < Time.current)
    end
    @posts = @posts.sort_by(&:created_at).reverse

    respond_to do |format|
      format.html
      format.js { render partial: 'posts/ajax_search', locals: { posts: @posts }, layout: false }
    end
  end

  def new
    @post = current_user.posts.build
  end

  def edit
    authorize! :edit, @post
  rescue CanCan::AccessDenied
    redirect_to root_path, alert: 'You are not authorized to perform this action.'
  end



  def show
    @comments = @post.comments.order(created_at: :asc)

    @comments.each do |comment|
      comment.define_singleton_method(:can_edit) { can? :update, comment }
      comment.define_singleton_method(:can_destroy) { can? :destroy, comment }
      comment.define_singleton_method(:can_report) { can? :report, comment }
    end
    @comment = Comment.new
    # Check if the post's user is suspended and not the current user
    if @post.user.suspended? && (!user_signed_in? || current_user.id != @post.user.id)
      redirect_back(fallback_location: root_path, alert: 'This post is currently unavailable.')
    end
  end


  def create
    @post = current_user.posts.build(post_params)
    if @post.save
      redirect_to root_path
    else
      render :new
    end
  end

  def update
    if @post.update(post_params)
      redirect_to root_path
    else
      render :edit
    end

  end

  def destroy
    @post.destroy
    redirect_to root_path
  end

  def archive
    @post = Post.find(params[:id])
    if @post.update(archived: true)
      redirect_to root_path, notice: 'Post was successfully archived.'
    else
      # Error handling...
    end
  end

  private

  def set_post
    @post = Post.find(params[:id])

  end

  def post_params
    params.require(:post).permit(:title, :body, :tag_list, :user_id)
  end
end
