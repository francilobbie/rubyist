import { Controller } from "@hotwired/stimulus";
import mapboxgl from "mapbox-gl";

export default class extends Controller {
  static values = {
    accessToken: String,
    mapStyle: String,
    companyCounts: Object
  };

  connect() {
    mapboxgl.accessToken = this.accessTokenValue;
    this.map = new mapboxgl.Map({
      container: this.element,
      style: this.mapStyleValue,
      center: [2.2137, 46.6276],
      zoom: 5
    });

    this.popup = new mapboxgl.Popup({
      closeButton: false,
      closeOnClick: false
    });

    this.map.on('load', () => {
      this.loadRegionsLayer();
      this.map.addControl(new mapboxgl.NavigationControl());
    });
  }

  loadRegionsLayer() {
    fetch('/departments_with_ids.geojson')
      .then(response => response.json())
      .then(data => {
        this.map.addSource('french-regions', {
          type: 'geojson',
          data: data
        });

        // Fill layer for regions
        this.map.addLayer({
          id: 'regions-fill',
          type: 'fill',
          source: 'french-regions',
          layout: {},
          paint: {
            'fill-color': '#888888',
            'fill-opacity': ['case',
              ['boolean', ['feature-state', 'hover'], false],
              0.75,  // Opacity for hovered state
              0.5    // Opacity for default state
            ]
          }
        });

        // Outline layer for regions
        this.map.addLayer({
          id: 'regions-outline',
          type: 'line',
          source: 'french-regions',
          layout: {},
          paint: {
            'line-color': '#000', // Black color for the border
            'line-width': ['case',
                ['boolean', ['feature-state', 'hover'], false],
                2,  // Line width when hovered
                0   // Line width by default (invisible)
            ]
          }
        });

        let hoveredRegionId = null;

        this.map.on('mousemove', 'regions-fill', e => {
          if (e.features.length > 0) {
            if (hoveredRegionId !== null) {
              this.map.setFeatureState(
                { source: 'french-regions', id: hoveredRegionId },
                { hover: false }
              );
            }
            hoveredRegionId = e.features[0].id;
            this.map.setFeatureState(
              { source: 'french-regions', id: hoveredRegionId },
              { hover: true }
            );
            this.map.setFeatureState(
              { source: 'french-regions', id: hoveredRegionId },
              { hover: true }
            );

            const properties = e.features[0].properties;
            const regionCode = properties.code;  // Corresponding to the GeoJSON feature properties
            const companyCount = this.companyCountsValue[regionCode] || 0;

            this.popup
              .setLngLat(e.lngLat)
              .setHTML(`<h4>${properties.nom}: ${companyCount} companies</h4>`)
              .addTo(this.map);
          }
        });

        this.map.on('mouseleave', 'regions-fill', () => {
          if (hoveredRegionId !== null) {
            this.map.setFeatureState(
              { source: 'french-regions', id: hoveredRegionId },
              { hover: false }
            );
            this.map.setFeatureState(
              { source: 'french-regions', id: hoveredRegionId },
              { hover: false }
            );
            hoveredRegionId = null;
          }
          this.popup.remove();
        });
      })
      .catch(err => console.error('Error loading GeoJSON data:', err));
  }

  disconnect() {
    if (this.map) {
      this.map.remove();
    }
  }
}
