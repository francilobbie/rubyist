# app/controllers/admin/users_controller.rb
class Admin::UsersController < Admin::BaseController
  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])

    # Separate role IDs update from other user attributes.
    update_roles_if_provided

    # Update other user attributes without role_ids to avoid unpermitted parameter warning.
    # In your update action, before the update(user_params) call
    _dummy = params[:user].delete(:role_ids) if params[:user][:role_ids]
    if @user.update(user_params)
      redirect_to admin_user_path(@user), notice: 'User was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to admin_users_url, notice: 'User was successfully destroyed.'
  end

  private

  def user_params
    params.require(:user).permit(:email, :id, :name, role_ids: [])
  end

  def update_roles_if_provided
    if params[:user][:role_ids]
      role_ids = params[:user][:role_ids].split(',').reject(&:empty?)
      @user.roles = Role.where(id: role_ids)
    elsif params[:user].key?(:role_ids)
      # Ensures roles are cleared only if role_ids key is present but empty.
      @user.roles.clear
    end
  end
end
