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
    @monthly_visitors = PostView.group_by_month(:created_at).count

    @most_viewed_posts = Post.joins(:post_views)
                             .group(:id)
                             .order('COUNT(post_views.id) DESC')
                             .limit(10)

    # Adjust donations calculations to avoid PG grouping errors
    @weekly_donations = Donation.group_by_week(:created_at, format: "%d %B %Y").sum(:amount).transform_values { |amount| amount / 100.0 }
    @total_donations = Donation.sum(:amount) / 100.0 # Convert from cents to euros

    @donations = Donation.includes(:user) # This can be fetched without any group-by clauses
  end

  def weekly_donations
    week_offset = params[:week_offset].to_i
    start_date = week_offset.weeks.ago.beginning_of_week
    end_date = start_date.end_of_week

    donations = Donation.where(created_at: start_date..end_date)
                        .group_by_day(:created_at, format: "%d %B %Y")
                        .sum(:amount)

    render json: {
      labels: donations.keys,  # Human-readable dates
      values: donations.values # Donation amounts
    }
  end

end
