# app/controllers/admin/dashboard_controller.rb
class Admin::DashboardController < Admin::BaseController
  def index
    @total_users = User.count
    @total_posts = Post.count
    @total_comments = Comment.count
    @recent_posts = Post.order(created_at: :desc).limit(5)
    @recent_comments = Comment.order(created_at: :desc).limit(5)
    @recent_users = User.order(created_at: :desc).limit(5)
    # Add more as needed for your dashboard
  end
end
