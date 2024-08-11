class ApplicationController < ActionController::Base

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.json { head :forbidden }
      format.html { redirect_to main_app.root_url, alert: exception.message }
    end
  end

  helper_method :ensure_admin_or_moderator!

  private

  # Ensures the current user is either an admin or a moderator
  def ensure_admin_or_moderator!
    redirect_back(fallback_location: root_path, alert: 'You are not authorized to perform this action.') unless user_is_admin_or_moderator?
  end

  # Checks if the current user has an admin or moderator role
  def user_is_admin_or_moderator?
    user_signed_in? && (current_user.has_role?(:admin) || current_user.has_role?(:moderator))
  end

end
