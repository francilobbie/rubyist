# app/controllers/reports_controller.rb
class ReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_report, only: [:show, :edit, :update]
  before_action :ensure_admin_or_moderator!, only: [:edit, :update, :destroy_comment]
  load_and_authorize_resource


  def index
    @reports = Report.all
    @recent_reports = Report.order(created_at: :desc).limit(5)

  end

  def new
    @report = Report.new(reportable_id: params[:reportable_id], reportable_type: params[:reportable_type])
  end

  def show
  end

  def create
    @report = current_user.reports.build(report_params)
    if @report.save
      redirect_to root_path, notice: 'The report has been submitted.'
    else
      render :new
    end
  end

  def edit
    @report = Report.find(params[:id])
  end

  def update
    @report = Report.find(params[:id])
    puts "Updating Report:", @report.inspect, "With Params:", report_params.inspect
    if @report.update(report_params)
      redirect_to moderation_path, notice: 'Report status updated successfully'
    else
      flash[:alert] = 'There was a problem updating the report.'
      render :edit
    end
  end

  def destroy_comment
    @report = Report.find(params[:id])

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

  end


  private

  def report_params
    params.require(:report).permit(:content, :reportable_id, :reportable_type, :category, :status)
  end

  def set_report
    @report = Report.find(params[:id])
  end
end
