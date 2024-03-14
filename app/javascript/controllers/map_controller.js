import { Controller } from "@hotwired/stimulus";
import L from "leaflet";

export default class extends Controller {
  static values = {
    companies: Array
  };

  connect() {
    this.map = this.initializeMap();
    // Initialize markersLayer and add it to the map
    this.markersLayer = L.layerGroup().addTo(this.map);
    this.addMarkers(this.companiesValue);

    // Listen for the custom cityChange event
    document.addEventListener('cityChange', this.handleCityChange.bind(this));
  }

  disconnect() {
    document.removeEventListener('cityChange', this.handleCityChange.bind(this));
    // Ensure to remove the map and layers to clean up resources
    if (this.map) {
      this.map.remove();
    }
  }

  initializeMap() {
    const map = L.map('map').setView([46.2276, 2.2137], 6);
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
    }).addTo(map);
    return map;
  }

  addMarkers(companies) {
    // Ensure to clear existing markers before adding new ones
    this.markersLayer.clearLayers();
    companies.forEach(company => {
      L.marker([company.latitude, company.longitude])
        .bindPopup(`${company.name} - ${company.city}`)
        .addTo(this.markersLayer);
    });
  }

  handleCityChange(event) {
    const city = event.detail.city;
    const filteredCompanies = city === "" ? this.companiesValue : this.companiesValue.filter(company => company.city === city);
    this.addMarkers(filteredCompanies);
    // Logic to adjust map view, if necessary
    if (filteredCompanies.length > 0) {
      this.fitMapToBounds(filteredCompanies);
    }
  }

  // Fit the map's bounds to the filtered companies
  fitMapToBounds(companies) {
    if (!companies.length) return;

    const bounds = L.latLngBounds(companies.map(company => [company.latitude, company.longitude]));
    this.map.fitBounds(bounds);
  }

}
