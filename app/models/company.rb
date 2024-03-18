class Company < ApplicationRecord
  validates :city, presence: true

  def self.regions_with_cities
    companies = Company.all
    regions_with_cities = {}

    companies.each do |company|
      regions_with_cities[company.region] ||= [] # Initialize the region array if it doesn't exist
      regions_with_cities[company.region] << company.city unless regions_with_cities[company.region].include?(company.city) # Avoid duplicating cities
    end

    regions_with_cities
  end

  def self.company_counts_by_region
    Company.group(:region).count
  end
  def self.company_counts_by_department_code
    # Group companies by 'region' and count them
    Company.group(:department_code).count
  end
end
