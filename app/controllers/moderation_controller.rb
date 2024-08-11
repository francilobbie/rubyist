# app/controllers/moderation_controller.rb
class ModerationController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin_or_moderator!


  def index
    @reports = Report.all.order(created_at: :desc)
  end

  private

  # def check_moderator
  #   redirect_to(root_path, alert: 'Not authorized') unless current_user.has_role?(:moderator)
  # end
end
