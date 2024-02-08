import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search"
export default class extends Controller {
  static targets = ["input", "form", "list"]

  connect() {
    this.handleKeyDown = this.handleKeyDown.bind(this);
    document.addEventListener('keydown', this.handleKeyDown, true);
    // Add focus event listener to the input target
    this.inputTarget.addEventListener('focus', this.showModal.bind(this));
  }

  disconnect() {
    document.removeEventListener('keydown', this.handleKeyDown, true);
    // Remove the focus event listener when the controller disconnects
    this.inputTarget.removeEventListener('focus', this.showModal.bind(this));
  }

  handleKeyDown(event) {
    if (event.ctrlKey && event.key.toLowerCase() === 'k') {
      event.preventDefault();
      this.showModal();
    } else if (event.key === 'Escape') {
      // this.blur();
      this.closeModal();
    }
  }

  focus() {
    this.inputTarget.focus();
    this.showModal();
  }

  blur() {
    this.inputTarget.blur();
  }

  showModal() {
    // Dispatch custom event to show the modal
    const showModalEvent = new CustomEvent('show-modal', { detail: { triggerId: "search-form" } });
    window.dispatchEvent(showModalEvent);
  }

  closeModal() {
    // Dispatch custom event to close the modal
    const closeModalEvent = new CustomEvent('close-modal', { detail: { triggerId: "search-form" } });
    window.dispatchEvent(closeModalEvent);
  }

  perform(event) {
    event.preventDefault();
    const query = this.inputTarget.value;
    const url = `${this.formTarget.action}?query=${encodeURIComponent(query)}&ajax=true`;

    fetch(url)
      .then(response => response.text())
      .then(html => {
        document.getElementById("search-results").innerHTML = html;
      })
      .catch(error => console.log("Error:", error));
  }

  updatePostsList(html) {
    const postsContainer = document.getElementById("search-results");
    postsContainer.innerHTML = html;
  }
}
