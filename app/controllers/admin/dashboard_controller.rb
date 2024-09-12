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

    @monthly_signups = User.group_by_month(:created_at).count
    @monthly_visitors = PostView.group_by_month(:created_at).count # If tracking visitors via post views
    @most_viewed_posts = Post.joins(:post_views)
                             .group(:id)
                             .order('COUNT(post_views.id) DESC')
                             .limit(10)

    @donations = Donation.includes(:user).all
    @weekly_donations = Donation.group_by_week(:created_at, format: "%d %B %Y").sum(:amount)
    @total_donations = Donation.sum(:amount)
    # Add more as needed for your dashboard
  end
end
