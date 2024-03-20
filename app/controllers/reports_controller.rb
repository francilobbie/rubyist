# app/controllers/reports_controller.rb
class ReportsController < ApplicationController
  before_action :authenticate_user!

  def new
    @report = Report.new(reportable_id: params[:reportable_id], reportable_type: params[:reportable_type])
  end

  def create
    @report = current_user.reports.build(report_params)
    if @report.save
      redirect_back(fallback_location: root_path, notice: 'The report has been submitted.')
    else
      render :new
    end
  end

  private

  def report_params
    params.require(:report).permit(:content, :reportable_id, :reportable_type)
  end
end
