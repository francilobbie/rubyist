# app/controllers/admin/dashboard_controller.rb
class Admin::DashboardController < Admin::BaseController
  def index
    @total_users = User.count
    @total_posts = Post.count
    @total_comments = Comment.count

    @recent_posts = Post.order(created_at: :desc).limit(5)
    @recent_comments = Comment.order(created_at: :desc).limit(5)
    @recent_users = User.order(created_at: :desc).limit(5)

    @published_posts = Post.published_post.order(published_at: :desc)
    @draft_posts = Post.draft.order(created_at: :desc)
    @scheduled_posts = Post.scheduled.order(published_at: :asc)

    # Add more as needed for your dashboard
  end
end
