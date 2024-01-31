import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search"
export default class extends Controller {
  static targets = [ "input" ]

  connect() {
    this.handleKeyDown = this.handleKeyDown.bind(this);
    document.addEventListener('keydown', this.handleKeyDown, true);
  }

  disconnect() {
    document.removeEventListener('keydown', this.handleKeyDown, true);
  }

  handleKeyDown(event) {
    if (event.ctrlKey && event.key.toLowerCase() === 'k') {
      event.preventDefault();
      this.focus();
    } else if (event.key === 'Escape') {
      event.preventDefault();
      this.blur();
    }
  }

  focus() {
    this.inputTarget.focus();
  }

  blur() {
    this.inputTarget.blur();
  }

}
