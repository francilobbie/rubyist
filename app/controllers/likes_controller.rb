class LikesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_likeable

  include ActionView::RecordIdentifier

  def create
    unless @likeable.likes.exists?(user: current_user)
      @like = @likeable.likes.create(user: current_user)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(dom_id(@likeable, :likes), partial: 'likes/like', locals: { likeable: @likeable })
        end
        format.html { redirect_back(fallback_location: root_path) }
      end
    end
  end

  def destroy
    @like = @likeable.likes.find(params[:id])
    @like.destroy
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(dom_id(@likeable, :likes), partial: 'likes/like', locals: { likeable: @likeable })
      end
      format.html { redirect_back(fallback_location: root_path) }
    end
  end

  private

  def find_likeable
    @likeable = if params[:comment_id]
                  Comment.find(params[:comment_id])
                else
                  Post.find(params[:post_id])
                end
  end
end
