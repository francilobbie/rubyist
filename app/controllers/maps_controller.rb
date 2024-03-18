class MapsController < ApplicationController
  def index
    @regions_with_cities = Company.regions_with_cities
    @company_counts = Company.company_counts_by_department_code
    @companies = if params[:city].present?
                   Company.where(city: params[:city])
                 else
                   Company.all
                 end
  end
end
