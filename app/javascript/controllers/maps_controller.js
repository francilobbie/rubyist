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

    document.addEventListener('departmentChange', this.handleDepartmentChange.bind(this));

  }

  loadRegionsLayer() {
    fetch('/departments_with_ids.geojson')
      .then(response => response.json())
      .then(data => {
        this.map.addSource('french-departments', {
          type: 'geojson',
          data: data
        });

        // Fill layer for departments
        this.map.addLayer({
          id: 'departments-fill',
          type: 'fill',
          source: 'french-departments',
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

        // Outline layer for departments
        this.map.addLayer({
          id: 'departments-outline',
          type: 'line',
          source: 'french-departments',
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

        this.map.on('mousemove', 'departments-fill', e => {
          if (e.features.length > 0) {
              if (hoveredRegionId !== null) {
                  this.map.setFeatureState({ source: 'french-departments', id: hoveredRegionId }, { hover: false });
              }
              hoveredRegionId = e.features[0].id;
              this.map.setFeatureState({ source: 'french-departments', id: hoveredRegionId }, { hover: true });

              // Ensure your GeoJSON properties match with these names
              const properties = e.features[0].properties;
              const departmentCode = properties.code;
              const companyCount = this.companyCountsValue[departmentCode] || 0;

              this.popup.setLngLat(e.lngLat).setHTML(`<h4>${properties.nom}: ${companyCount} companies</h4>`).addTo(this.map);
          }
      });

      this.map.on('mouseleave', 'departments-fill', () => {
          if (hoveredRegionId !== null) {
              this.map.setFeatureState({ source: 'french-departments', id: hoveredRegionId }, { hover: false });
              hoveredRegionId = null;
          }
          this.popup.remove();
      });
      })
      .catch(err => console.error('Error loading GeoJSON data:', err));
  }

  handleDepartmentChange(event) {
    const departmentCode = event.detail.code;
    // Check if departmentCode is empty
    if (!departmentCode) {
        // Set the map back to the default center and zoom
        this.map.flyTo({
            center: [2.2137, 46.6276], // Default center coordinates
            zoom: 5, // Default zoom level
        });
    } else {
        // Handle zooming to the department as before
        const departmentSource = this.map.getSource('french-departments');
        if (departmentSource && departmentSource._data && departmentSource._data.features) {
            const departmentFeature = departmentSource._data.features.find(feature => feature.properties.code === departmentCode);
            if (departmentFeature) {
                const geometryType = departmentFeature.geometry.type;
                const coordinates = departmentFeature.geometry.coordinates;
                const bounds = this.calculateBoundingBox(coordinates, geometryType);
                if (bounds) {
                    this.map.fitBounds(bounds, { padding: 20 });
                }
            } else {
                console.log('Department feature missing in the data');
            }
        } else {
            console.log('Source not loaded or department data missing');
        }
    }
  }


  calculateBoundingBox(coordinates, type) {
    let bounds = new mapboxgl.LngLatBounds();

    const addPointToBounds = (point) => {
        bounds.extend(mapboxgl.LngLat.convert([point[0], point[1]]));
    };

    if (type === 'Polygon') {
        coordinates.forEach(polygon => polygon.forEach(addPointToBounds));
    } else if (type === 'MultiPolygon') {
        coordinates.forEach(polygon => polygon.forEach(ring => ring.forEach(addPointToBounds)));
    }

    return bounds.isEmpty() ? null : bounds;
  }




  disconnect() {
    if (this.map) {
      this.map.remove();
      document.removeEventListener('departmentChange', this.handleDepartmentChange);
    }
  }
}
