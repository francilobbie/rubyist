class MapsController < ApplicationController
  def index
    @regions_with_cities = Company.regions_with_cities
    @companies = if params[:city].present?
                   Company.where(city: params[:city])
                 else
                   Company.all
                 end
  end
end
