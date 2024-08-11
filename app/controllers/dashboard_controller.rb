class DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin_or_moderator!

  def show
    # Dashboard information here. For example:
    @recent_posts = Post.order(created_at: :desc).limit(5)
    @recent_comments = Comment.order(created_at: :desc).limit(5)
    @recent_signups = User.order(created_at: :desc).limit(5)
    @recent_reports = Report.order(created_at: :desc).limit(5)
    @reports = Report.all.order(created_at: :desc)
  end

  private

  def ensure_admin_or_moderator!
    unless current_user.has_role?(:admin) || current_user.has_role?(:moderator)
      flash[:alert] = 'You are not authorized to access this page.'
      redirect_to root_path
    end
  end
end
