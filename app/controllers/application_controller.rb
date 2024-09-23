class ApplicationController < ActionController::Base
  include Pagy::Backend

  require 'pagy/extras/array'


  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_notifications, if: :user_signed_in?
  before_action :set_subscription, if: :user_signed_in?


  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.json { head :forbidden }
      format.html { redirect_to main_app.root_url, alert: exception.message }
    end
  end

  helper_method :ensure_admin_or_moderator!



  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [profile_attributes: [:first_name, :last_name]])
  end

  private

  def set_notifications
    @notifications = current_user.notifications.unread
  end

  # Ensures the current user is either an admin or a moderator
  def ensure_admin_or_moderator!
    redirect_back(fallback_location: root_path, alert: 'You are not authorized to perform this action.') unless user_is_admin_or_moderator?
  end

  # Checks if the current user has an admin or moderator role
  def user_is_admin_or_moderator?
    user_signed_in? && (current_user.has_role?(:admin) || current_user.has_role?(:moderator))
  end

  def set_subscription
    if current_user
      @subscription = Subscription.find_by(email: current_user.email) || Subscription.new(email: current_user.email)
    else
      @subscription = Subscription.new
    end
  end

end
