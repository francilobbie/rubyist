class PostsController < ApplicationController
  load_and_authorize_resource

  before_action :set_post, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]

  def index
    base_query = params[:query].present? ? Post.published_post.global_search(params[:query]) : Post.published_post
    all_posts = base_query.includes(:user).sort_by(&:created_at).reverse

    @pagy, @posts = pagy_array(all_posts.select do |post|
      !post.user.suspended? || (post.user.suspended? && post.user.suspended_until.present? && post.user.suspended_until < Time.current)
    end, items: 10)

    Rails.logger.info "Pagination items per page: #{@pagy.vars[:items]}"
    Rails.logger.info "Number of posts being shown: #{@posts.count}"

    respond_to do |format|
      format.html
      format.js { render partial: 'posts/ajax_search', locals: { posts: @posts }, layout: false }
    end

  rescue Pagy::OverflowError
    redirect_to root_path(page: 1), alert: 'Cette page n\'existe pas.'
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
    logger.debug "Post attributes: #{@post.attributes.inspect}"

    @can_edit_post = can?(:update, @post)
    @can_destroy_post = can?(:destroy, @post)
    @can_destroy_tag = can?(:destroy, Tag)
    @can_report_post = can?(:report, @post)

    track_post_view

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

    # Handle publish option logic
    case params[:post][:publish_option]
    when "publish_now"
      @post.published_at = Time.current
    when "draft"
      @post.published_at = nil
    end

    if @post.save
      redirect_to root_path, notice: 'Post was successfully created.'
    else
      flash[:alert] = @post.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end


  def update

    # Handle publish option logic
    case params[:post][:publish_option]
    when "publish_now"
      @post.published_at = Time.current
    when "draft"
      @post.published_at = nil
    end

    if @post.update(post_params)
      @post.broadcast_update_with_permissions(current_user)
      redirect_to post_path(@post), notice: 'Post was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end


  def destroy
    @post.destroy
    redirect_to root_path
  end

  def archive
    if @post.update(archived: true)
      redirect_to root_path, notice: 'Post was successfully archived.'
    else
      redirect_to root_path, alert: 'Failed to archive the post.'
    end
  end

  def unpublish
    if @post.update(published_at: nil)
      redirect_to edit_post_path(@post), notice: 'Post has been unpublished and can be edited again.'
    else
      redirect_to edit_post_path(@post), alert: 'Failed to unpublish the post.'
    end
  end



  private

  def track_post_view
    return track_guest_view unless current_user

    # Only track view if user hasn't viewed this post before
    unless PostView.exists?(user_id: current_user.id, post_id: @post.id)
      PostView.create(user: current_user, post: @post)
    end
  end

  def track_guest_view
    session[:viewed_posts] ||= []
    return if session[:viewed_posts].include?(@post.id)

    @post.post_views.create(user: nil)
    session[:viewed_posts] << @post.id
  end

  def set_post
    @post = if user_signed_in?
              Post.find(params[:id])
            else
              Post.published_post.find_by(id: params[:id])
            end

    redirect_to root_path, alert: 'Post not found or not published.' unless @post
  end


  def post_params
    params.require(:post).permit(:title, :body, :tag_list, :published_at)
  end
end
