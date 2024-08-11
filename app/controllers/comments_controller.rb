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
      if @comment.parent_id.present?
        parent_comment = Comment.find_by(id: @comment.parent_id)
        broadcast_reply(@comment, parent_comment) if parent_comment
      else
        broadcast_new_comment(@comment)
      end
      redirect_to @post, notice: 'Comment was successfully posted.'
    else
      render :new, status: :unprocessable_entity
    end
  end


  def edit
    # Just display the edit form
    @post = Post.find(params[:post_id])
  end

  # CommentsController
  def update
    @comment = Comment.find(params[:id])
    authorize! :update, @comment

    respond_to do |format|
      if @comment.update(comment_params)
        # Replace the comment directly without broadcast if update is successful
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(@comment,
                                                    partial: "comments/comment",
                                                    locals: { comment: @comment,
                                                              post: @post,
                                                              current_user: current_user,
                                                              can_edit: can?(:update, @comment),
                                                              can_destroy: can?(:destroy, @comment),
                                                              can_report: can?(:report, @comment)})
        end
        format.html { redirect_to @post, notice: 'Comment was successfully updated.' }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end




  # DELETE /posts/:post_id/comments/:id
  def destroy
    authorize! :destroy, @comment
    @comment.destroy
    redirect_to @post, notice: 'Comment was successfully deleted.'
  end

  def archive
    @comment = Comment.find(params[:id])
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


  def authorize_modification
    authorize! :manage, @comment
  end

  def comment_params
    params.require(:comment).permit(:content, :parent_id)
  end

  def broadcast_reply(comment, parent_comment)
    Turbo::StreamsChannel.broadcast_append_to(
      [@post, :comments], # Assuming :comments is a stream associated with the post
      target: "replies_for_comment_#{dom_id(parent_comment)}",
      partial: "comments/comment",
      locals: { comment: comment }
    )
  end


  def broadcast_new_comment(comment)
    Turbo::StreamsChannel.broadcast_prepend_to(
      [@post, :comments], # Assuming :comments is a stream associated with the post
      target: "comments",
      partial: "comments/comment",
      locals: { comment: comment, can_edit: can?(:update, comment), can_destroy: can?(:destroy, comment), can_report: can?(:report, comment) }
    )
  end

end
