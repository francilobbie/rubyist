class PostsController < ApplicationController
  load_and_authorize_resource

  before_action :set_post, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]

  def index
    base_query = params[:query].present? ? Post.published.global_search(params[:query]) : Post.published
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

    @can_edit_post = can?(:update, @post)
    @can_destroy_post = can?(:destroy, @post)
    @can_destroy_tag = can?(:destroy, Tag)
    @can_report_post = can?(:report, @post)

    @comments = @post.comments.order(created_at: :asc)
    @comments.each do |comment|
      comment.define_singleton_method(:can_edit) { can?(:update, comment) }
      comment.define_singleton_method(:can_destroy) { can?(:destroy, comment) }
      comment.define_singleton_method(:can_report) { can?(:report, comment) }
    end
    @comment = Comment.new
  end

  def create
    @post = current_user.posts.build(post_params)

    if @post.save
      redirect_to root_path, notice: 'Post was successfully created.'
    else
      flash[:alert] = @post.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end


  def update
    if @post.update(post_params)
      @post.broadcast_update_with_permissions(current_user)
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

  def unpublish
    @post = Post.find(params[:id])
    @post.update(published_at: nil)
    redirect_to edit_post_path(@post), notice: 'Post has been unpublished and can be edited again.'
  end


  private

  def set_post
      @post = user_signed_in? ? Post.find(params[:id]) : Post.published.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :body, :tag_list, :user_id, :published_at)
  end
end
