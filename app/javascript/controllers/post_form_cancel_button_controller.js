import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="post-form-cancel-button"
export default class extends Controller {
  static targets = ["form"]

  connect() {
    console.log("Connected to post-form-cancel-button controller");
    this.formTargets.forEach((form) => {
      form.addEventListener("change", () => this.formDirty = true)
    })
  }

  cancel(event) {
    if(this.formDirty && !confirm("Are you sure you want to cancel? Unsaved changes will be lost.")) {
      event.preventDefault()
    } else {
      // Reset the dirty form flag or redirect to the given path
      this.formDirty = false;
      // Redirect to a specific path if necessary
      // window.location.href = "/your/specific/path";
    }
  }
}
