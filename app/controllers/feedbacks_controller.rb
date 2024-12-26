class FeedbacksController < ApplicationController
  before_action :authenticate_user!, only: [ :create]

  def new
    @feedback = Feedback.new
  end

  def create
    @feedback = current_user.feedbacks.build(feedback_params)

    if @feedback.save
      FeedbackMailer.notify_admin(@feedback).deliver_later

      # Send confirmation to the user
      FeedbackMailer.confirm_feedback_submission(@feedback).deliver_later

      redirect_to root_path, notice: 'Merci pour votre retour, nous allons examiner votre feedback.'
    else
      flash[:alert] = "Impossible d'envoyer le retour, veuillez réessayer."
      render :new
    end
  end

  private

  def feedback_params
    params.require(:feedback).permit(:name, :content, :category)
  end
end
