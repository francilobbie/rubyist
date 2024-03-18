class MapsController < ApplicationController
  include FrenchGeography


  def index
    @departments = FrenchGeography::ALL_DEPARTMENTS
    @regions_with_cities = Company.regions_with_cities
    @company_counts = Company.company_counts_by_department_code
    @companies = if params[:city].present?
                   Company.where(city: params[:city])
                 else
                   Company.all
                 end
  end
end
