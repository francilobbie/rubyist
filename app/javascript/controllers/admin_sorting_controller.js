import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="admin-sorting"
export default class extends Controller {
  static targets = ["table"];

  connect() {
    console.log("Admin sorting controller connected");
  }

  sort(event) {
    event.preventDefault();
    const sortKey = event.target.getAttribute('data-sorting-key');
    const tableType = event.target.getAttribute('data-table-type');
    const url = new URL(window.location);
    url.searchParams.set('sort', sortKey);
    url.searchParams.set('table_type', tableType);

    fetch(url, {
      headers: {
        'Accept': 'text/vnd.turbo-stream.html',
        'Cache-Control': 'no-cache'
      },
    })
    .then(response => response.text())
    .then(html => {
      const parser = new DOMParser();
      const doc = parser.parseFromString(html, "text/html");
      Turbo.renderStreamMessage(doc.documentElement.innerHTML);
    })
    .catch(error => console.error("Failed to process sorting:", error));
  }
}
