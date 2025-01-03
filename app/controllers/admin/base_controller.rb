# app/controllers/admin/base_controller.rb
module Admin
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :check_admin

    private

    def check_admin
      redirect_to root_path, alert: 'Not authorized' unless current_user.has_role? :admin
    end
  end
end
