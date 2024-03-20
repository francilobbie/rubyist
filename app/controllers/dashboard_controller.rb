class DashboardController < ApplicationController
  before_action :authenticate_user!

  def show
    # Dashboard information here. For example:
    @recent_posts = Post.order(created_at: :desc).limit(5)
    @recent_comments = Comment.order(created_at: :desc).limit(5)
    @recent_signups = User.order(created_at: :desc).limit(5)
    @recent_reports = Report.order(created_at: :desc).limit(5) # Assuming you have a Report model
    # Include more context as per your app needs
  end
end
