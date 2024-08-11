# app/controllers/comments_controller.rb
class CommentsController < ApplicationController
  include ActionView::RecordIdentifier

  before_action :authenticate_user!
  before_action :set_post, only: [:create, :edit, :update, :destroy, :archive]
  before_action :set_comment, only: [:edit, :update, :destroy, :archive]

  # POST /posts/:post_id/comments
  def create
    @comment = @post.comments.build(comment_params.merge(user: current_user))

    if @comment.save
      can_edit = can?(:update, @comment)
      can_destroy = can?(:destroy, @comment)
      can_report = can?(:report, @comment)

      if @comment.parent_id.present?
        parent_comment = Comment.find_by(id: @comment.parent_id)
        @comment.broadcast_reply(parent_comment, can_edit, can_destroy, can_report) if parent_comment
      else
        @comment.broadcast_new_comment(can_edit, can_destroy, can_report)
      end

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @post, notice: 'Comment was successfully posted.' }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end



  def edit
    @post = Post.find(params[:post_id])
  end

  def update
    authorize! :update, @comment

    if @comment.update(comment_params)
      can_edit = can?(:update, @comment)
      can_destroy = can?(:destroy, @comment)
      can_report = can?(:report, @comment)
      @comment.update_and_broadcast(can_edit, can_destroy, can_report)
      render turbo_stream: turbo_stream.replace(@comment, partial: "comments/comment", locals: comment_locals(@comment))
    else
      render :edit, status: :unprocessable_entity
    end
  end


  def destroy
    authorize! :destroy, @comment
    @comment.destroy
    broadcast_remove_comment(@comment)
    redirect_to @post, notice: 'Comment was successfully deleted.'
  end

  def archive
    if @comment.update(archived: true)
      redirect_to root_path, notice: 'Comment was successfully archived.'
    else
      # Error handling...
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def set_comment
    @comment = @post.comments.find_by(id: params[:id])
    unless @comment
      redirect_to @post, alert: 'Comment not found.'
    end
  end

  def comment_params
    params.require(:comment).permit(:content, :parent_id)
  end

  def comment_locals(comment)
    {
      comment: comment,
      can_edit: can?(:update, comment),
      can_destroy: can?(:destroy, comment),
      can_report: can?(:report, comment)
    }
  end


  def broadcast_reply(comment, parent_comment)
    Turbo::StreamsChannel.broadcast_append_to(
      [@post, :comments],
      target: "replies_for_comment_#{dom_id(parent_comment)}",
      partial: "comments/comment",
      locals: comment_locals(comment)
    )
  end

  def broadcast_new_comment(comment)
    Turbo::StreamsChannel.broadcast_prepend_to(
      [@post, :comments],
      target: "comments",
      partial: "comments/comment",
      locals: comment_locals(comment)
    )
  end

  def broadcast_replace_comment(comment)
    Turbo::StreamsChannel.broadcast_replace_to(
      [comment.post, :comments],
      target: dom_id(comment),
      partial: "comments/comment",
      locals: comment_locals(comment)
    )
  end


  def broadcast_remove_comment(comment)
    Turbo::StreamsChannel.broadcast_remove_to(
      [comment.post, :comments],
      target: dom_id(comment)
    )
  end
end
