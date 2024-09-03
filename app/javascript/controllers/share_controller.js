import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="share"
export default class extends Controller {
  connect() {}

  share(e) {
    e.preventDefault();
    document.getElementById("share-modal-trigger").click();
  }
}
