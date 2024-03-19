# app/controllers/comments_controller.rb
class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post
  before_action :set_comment, only: [:edit, :update, :destroy]
  before_action :authorize_modification, only: [:edit, :update, :destroy]

  def create
    @comment = @post.comments.build(comment_params.merge(user: current_user))
    authorize! :create, @comment

    if @comment.save
      redirect_to @post, notice: 'Comment was successfully added.'
    else
      redirect_to @post, alert: 'Unable to add comment.'
    end
  end

  def edit
    # Just display the edit form
  end

  def update
    if @comment.update(comment_params)
      redirect_to @post, notice: 'Comment was successfully updated.'
    else
      render :edit, alert: 'Unable to update comment.'
    end
  end

  def destroy
    @comment.destroy
    redirect_to @post, notice: 'Comment was successfully deleted.'
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def set_comment
    @comment = @post.comments.find(params[:id])
  end

  def authorize_modification
    authorize! :manage, @comment
  end

  def comment_params
    params.require(:comment).permit(:content)
  end
end
