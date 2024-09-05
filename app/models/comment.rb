class Comment < ApplicationRecord
  include ActionView::RecordIdentifier

  belongs_to :post
  belongs_to :user
  belongs_to :parent, class_name: 'Comment', optional: true
  has_many :replies, class_name: 'Comment', foreign_key: :parent_id, dependent: :destroy
  has_many :likes, as: :likeable, dependent: :destroy
  has_many :mentions, as: :mentionable, dependent: :destroy



  validates :content, presence: true

  after_create_commit :broadcast_prepend_comment
  after_destroy_commit :broadcast_remove_comment

  before_save :process_content
  after_save :update_mentions

  after_create_commit :notify_mentioned_users
  after_create_commit :notify_comment_or_reply

  def notify_reply
    if parent_id.present? # Notify only if this is a reply
      notify_reply_user(self.user, self.parent)
    end
  end

  def notify_comment
    notify_post_user(self.user, self.post) if parent_id.nil? # Notify only for top-level comments
  end


  scope :top_level, -> { where(parent_id: nil) }

  def update_and_broadcast(can_edit, can_destroy, can_report)
    broadcast_replace_comment(can_edit, can_destroy, can_report)
  end

  def broadcast_reply(parent_comment, can_edit, can_destroy, can_report)
    locals = {
      comment: self,
      can_edit: can_edit,
      can_destroy: can_destroy,
      can_report: can_report
    }

    broadcast_prepend_later_to(
      [post, :comments],
      target: "replies_for_comment_#{dom_id(parent_comment)}",
      partial: "comments/comment",
      locals: locals
    )
  end

  def broadcast_new_comment(can_edit, can_destroy, can_report)
    locals = {
      comment: self,
      can_edit: can_edit,
      can_destroy: can_destroy,
      can_report: can_report
    }

    broadcast_prepend_later_to(
      [post, :comments],
      target: "comments",
      partial: "comments/comment",
      locals: locals
    )
  end

  private

  def broadcast_prepend_comment
    # Assuming that these variables were passed as arguments, but you didn't provide them
    # Remove this method if the permissions should be handled at the controller level
    can_edit = true  # or false or whatever logic you have
    can_destroy = true  # same as above
    can_report = true  # same as above

    locals = {
      comment: self,
      can_edit: can_edit,
      can_destroy: can_destroy,
      can_report: can_report
    }

    if parent_id.present?
      broadcast_prepend_later_to [post, :comments], target: "replies_for_comment_#{parent_id}", partial: "comments/comment", locals: locals
    else
      broadcast_prepend_later_to [post, :comments], target: "comments", partial: "comments/comment", locals: locals
    end
  end

  def broadcast_remove_comment
    broadcast_remove_to [post, :comments], target: dom_id(self)
  end

  def broadcast_replace_comment(can_edit, can_destroy, can_report)
    locals = {
      comment: self,
      can_edit: can_edit,
      can_destroy: can_destroy,
      can_report: can_report
    }

    broadcast_replace_later_to(
      [post, :comments],
      target: dom_id(self),
      partial: "comments/comment",
      locals: locals
    )
  end

  def process_content
    self.content = process_content_with_mentions(content)
  end

  def process_content_with_mentions(content)
    content.gsub(/@(\w+)/) do |mention|
      username = mention.delete('@')
      user = User.find_by(username: username)

      if user
        # Create a new Mention record
        mentions.build(user: user, content: content)
        "@[#{username}](#{user.id})"
      else
        mention
      end
    end
  end

  def update_mentions
    mentions.destroy_all # Clear existing mentions
    process_content_with_mentions(content) # Reprocess the content
  end

  def mentioned_users
    mentioned_usernames = content.scan(/@\[(.*?)\]\((\d+)\)/).map { |username, id| User.find_by(id: id) }
    mentioned_usernames.compact
  end

  def notify_mentioned_users
    mentioned_users.each do |mentioned_user|
      MentionNotification.with(
        message: "#{user.full_name} mentioned you in a comment",
        url: Rails.application.routes.url_helpers.post_path(post, anchor: "comment-#{id}")
      ).deliver_later(mentioned_user)
    end
  end

  def notify_comment_or_reply
    if parent_id.present?
      notify_reply
    else
      notify_comment
    end
  end

  def notify_reply
    parent_comment = Comment.find_by(id: parent_id)
    if parent_comment && parent_comment.user != user
      ReplyNotification.with(
        message: "#{user.full_name} replied to your comment",
        url: Rails.application.routes.url_helpers.post_comment_path(parent_comment.post, parent_comment, anchor: "comment-#{parent_comment.id}")
      ).deliver_later(parent_comment.user)
    end
  end

  def notify_comment
    if post.user != user
      CommentNotification.with(
        message: "#{user.full_name} commented on your post",
        url: Rails.application.routes.url_helpers.post_path(post, anchor: "comment-#{id}")
      ).deliver_later(post.user)
    end
  end

end
