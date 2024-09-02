# app/controllers/reports_controller.rb
class ReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_report, only: [:show, :edit, :update, :destroy_comment]
  before_action :ensure_admin_or_moderator!, only: [:edit, :update, :destroy_comment]
  load_and_authorize_resource

  def index
    @reports = Report.all
    @recent_reports = Report.order(created_at: :desc).limit(5)
  end

  def new
    # Ensure the user is authorized to create a report
    authorize! :create, Report
    @report = Report.new(reportable_id: params[:reportable_id], reportable_type: params[:reportable_type])
  rescue CanCan::AccessDenied => e
    Rails.logger.debug "Access Denied: #{e.message}"
    redirect_to root_path, alert: "You are not authorized to report this item."
  end

  def show
  end

  def create
    @report = current_user.reports.build(report_params)
    authorize! :create, @report

    if @report.save
      notify_admins_and_moderators(@report)
      redirect_to root_path, notice: 'The report has been submitted.'
    else
      Rails.logger.debug "Report creation failed: #{@report.errors.full_messages.join(", ")}"
      flash[:alert] = 'There was an issue submitting your report. Please check the form and try again.'
      render :new
    end
  rescue CanCan::AccessDenied => e
    Rails.logger.debug "Access Denied: #{e.message}"
    redirect_to root_path, alert: "You are not authorized to submit this report."
  end


  def edit
    authorize! :update, @report
  rescue CanCan::AccessDenied => e
    Rails.logger.debug "Access Denied: #{e.message}"
    redirect_to root_path, alert: "You are not authorized to edit this report."
  end

  def update
    authorize! :update, @report
    if @report.update(report_params)
      redirect_to moderation_path, notice: 'Report status updated successfully'
    else
      flash[:alert] = 'There was a problem updating the report.'
      render :edit
    end
  rescue CanCan::AccessDenied => e
    Rails.logger.debug "Access Denied: #{e.message}"
    redirect_to root_path, alert: "You are not authorized to update this report."
  end

  def destroy_comment
    authorize! :destroy, @report

    if @report.reportable_type == 'Comment'
      comment = Comment.find_by(id: @report.reportable_id)
      if comment
        comment.destroy
        redirect_to dashboard_show_path, notice: 'Comment was successfully deleted.'
      else
        redirect_to dashboard_show_path, alert: 'Comment not found.'
      end
    else
      redirect_to dashboard_show_path, alert: 'Report is not for a comment.'
    end
  rescue CanCan::AccessDenied => e
    Rails.logger.debug "Access Denied: #{e.message}"
    redirect_to root_path, alert: "You are not authorized to delete this comment."
  end

  private

  def report_params
    params.require(:report).permit(:content, :reportable_id, :reportable_type, :category, :status)
  end

  def set_report
    @report = Report.find(params[:id])
  end

  def ensure_admin_or_moderator!
    unless current_user.has_role?(:admin) || current_user.has_role?(:moderator)
      redirect_to root_path, alert: "You are not authorized to perform this action."
    end
  end

  def notify_admins_and_moderators(report)
    User.with_role(:admin).or(User.with_role(:moderator)).each do |user|
      NewReportNotificationNotifier.with(report: report).deliver_later(user)
    end
  end

end
