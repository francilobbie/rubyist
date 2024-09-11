# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  def new
    build_resource({})
    resource.build_profile # Ensure profile is initialized
    respond_with self.resource
  end

  # POST /resource
  def create
    build_resource(sign_up_params)
    resource.build_profile # Ensure profile is initialized before saving

    super do |resource|
      if resource.persisted?
        UserMailer.welcome_email(resource).deliver_now
      end
    end
  end

  # GET /resource/edit
  def edit
    super
  end

  # PUT /resource
  def update
    super
  end

  # DELETE /resource
  def destroy
    super
  end

  # GET /resource/cancel
  def cancel
    super
  end

  # If you have extra params to permit, append them to the sanitizer.
  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [profile_attributes: [:first_name, :last_name]])
  end

  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [profile_attributes: [:first_name, :last_name]])
  end
end
