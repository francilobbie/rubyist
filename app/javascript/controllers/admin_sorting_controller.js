import { Controller } from "@hotwired/stimulus"


// Connects to data-controller="admin-sorting"
export default class extends Controller {
  static targets = ["table"];

  connect() {
    console.log("Admin sorting controller connected"); // Check if this logs in your browser console
  }

  sort(event) {
    event.preventDefault();
    console.log("Sorting by:", event.target.getAttribute('data-sorting-key'));
    const sortKey = event.target.getAttribute('data-sorting-key');
    const tableType = event.target.getAttribute('data-table-type'); // Ensure your HTML has this attribute
    const url = new URL(window.location);
    url.searchParams.set('sort', sortKey);
    url.searchParams.set('table_type', tableType); // Add this line

    // This is the request that should correctly handle Turbo Stream responses.
    fetch(url, {
      headers: { 'Accept': 'text/vnd.turbo-stream.html' },
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
