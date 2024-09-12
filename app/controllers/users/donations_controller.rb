# app/controllers/users/donations_controller.rb
class Users::DonationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @donations = current_user.donations
  end
end
