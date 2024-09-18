# app/controllers/users/donations_controller.rb
class Users::DonationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @donations = current_user.donations.order(created_at: :desc) # Fetch donations for the current user and order by latest first
  end
end
