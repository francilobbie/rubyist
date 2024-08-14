# app/controllers/admin/posts_controller.rb
module Admin
  class PostsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_post, only: [:show, :edit, :update, :destroy]
    before_action :authorize_admin!

    def index
      @published_posts = Post.published_post.order(published_at: :desc)
      @draft_posts = Post.draft.order(created_at: :desc)
      @scheduled_posts = Post.scheduled.order(published_at: :asc)
    end

    def show
      @can_edit_post = can?(:update, @post)
      @can_destroy_post = can?(:destroy, @post)
      @can_destroy_tag = can?(:destroy, Tag)
      @can_report_post = can?(:report, @post)
    end

    def new
      @post = Post.new
    end

    def create
      @post = Post.new(post_params)
      if @post.save
        redirect_to admin_post_path(@post), notice: 'Post was successfully created.'
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @post.update(post_params)
        redirect_to admin_post_path(@post), notice: 'Post was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @post.destroy
      redirect_to admin_posts_path, notice: 'Post was successfully deleted.'
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
      @post = Post.find(params[:id])
    end

    def post_params
      params.require(:post).permit(:title, :body, :tag_list, :published_at)
    end

    def authorize_admin!
      redirect_to root_path, alert: 'You are not authorized to access this page.' unless current_user.has_role?(:admin)
    end
  end
end
