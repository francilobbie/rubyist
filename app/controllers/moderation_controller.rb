# app/controllers/moderation_controller.rb
class ModerationController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource :report

  def index
    @reports = Report.all
  end
end
class ModerationController < ApplicationController
  def index
  end
end
