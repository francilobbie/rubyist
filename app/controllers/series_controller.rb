class SeriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_series, only: [:show, :edit, :update, :destroy]
  before_action :authorize_series, only: [:edit, :update, :destroy]

  def index
    @series = current_user.series
  end

  def new
    @series = Series.new
  end

  def create
    @series = current_user.series.build(series_params)
    if @series.save
      redirect_to @series, notice: 'Series created successfully.'
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @series.update(series_params)
      redirect_to @series, notice: 'Series updated successfully.'
    else
      render :edit
    end
  end

  def destroy
    @series.destroy
    redirect_to root_path, notice: 'Series deleted successfully.'
  end

  private

  def series_params
    params.require(:series).permit(:title, :description)
  end

  def set_series
    @series = Series.find_by(id: params[:id])
    if @series.nil?
      redirect_to root_path, alert: "Series not found."
    end
  end

  def authorize_series
    unless @series.user == current_user
      redirect_to @series, alert: "You are not authorized to modify this series."
    end
  end
end
