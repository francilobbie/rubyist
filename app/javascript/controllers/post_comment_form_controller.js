import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="post-comment-form"
export default class extends Controller {
  static targets = ["form"]

  connect() {
    this.element.addEventListener('turbo:submit-end', () => {
      this.resetForm();
    });
  }

  resetForm() {
    try {
      this.formTarget.reset();
    } catch (error) {
    }
  }

}
