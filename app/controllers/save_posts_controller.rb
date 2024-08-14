class SavePostsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_post

  include ActionView::RecordIdentifier

  def create
    unless @post.save_posts.exists?(user: current_user)
      @save_post = @post.save_posts.create(user: current_user)
      @save_post.save
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("#{dom_id(@post, :save)}", partial: 'save_posts/save', locals: { post: @post }) }
        format.html { redirect_back(fallback_location: root_path) }
      end
    end
  end

  def destroy
    @save_post = @post.save_posts.find_by(user: current_user)
    @save_post&.destroy
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace("#{dom_id(@post, :save)}", partial: 'save_posts/save', locals: { post: @post }) }
      format.html { redirect_back(fallback_location: root_path) }
    end
  end

  private

  def find_post
    @post = Post.find(params[:post_id])
  end
end
