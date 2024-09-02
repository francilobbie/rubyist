import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="notifications"

export default class extends Controller {
  static targets = ["lightbox", "indexList", "dropdownList"];

  connect() {
    // This method runs when the controller connects to the DOM.
  }

  toggle() {
    this.lightboxTarget.classList.toggle("hidden");
  }

  // Additional methods for other targets
}
