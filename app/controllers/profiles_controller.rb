class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user
  before_action :set_profile, only: [:show, :edit, :update]

  def show
    authorize! :read, @profile
  end

  def edit
    authorize! :update, @profile
  end

  def update
    authorize! :update, @profile
    if @user.update(user_params) && @profile.update(profile_params)
      redirect_to user_profile_path(@user), notice: 'Profile was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def set_profile
    @profile = @user.profile
    authorize! :read, @profile
  end

  def profile_params
    params.require(:profile).permit(:first_name, :last_name, :bio, :avatar)
  end

  def user_params
    params.require(:user).permit(:username)
  end
end
