# app/controllers/comments_controller.rb
class CommentsController < ApplicationController
  before_action :authenticate_user!, only: :create

  def create
    @post = Post.find(params[:post_id])
    @comment = @post.comments.build(comment_params.merge(user: current_user))

    if @comment.save
      redirect_to @post, notice: 'Comment was successfully added.'
    else
      redirect_to @post, alert: 'Unable to add comment.'
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:content)
  end
end
