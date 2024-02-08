import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search"
export default class extends Controller {
  static targets = ["input", "form", "list", "quickSearch"]

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
      this.showModal();
    } else if (event.key === 'Escape') {
      this.closeModal();
    }
  }

  focus() {
    this.inputTarget.focus();
  }

  showModal() {
    const showModalEvent = new CustomEvent('show-modal', { detail: { triggerId: "search-form" } });
    window.dispatchEvent(showModalEvent);

    setTimeout(() => {
      const input = document.querySelector("[data-controller='search'] [data-search-target='input']");
      if (input) {
        input.focus();
      }
    }, 150);
  }


  closeModal() {
    // Dispatch custom event to close the modal
    const closeModalEvent = new CustomEvent('close-modal', { detail: { triggerId: "search-form" } });
    window.dispatchEvent(closeModalEvent);
  }


  perform(event) {
    event.preventDefault();
    const query = this.inputTarget.value; // Ensure this retrieves the correct value
    const url = `${this.formTarget.action}?query=${encodeURIComponent(query)}&ajax=true`;

    fetch(url, { headers: { "Accept": "text/html" } })
      .then(response => response.text())
      .then(html => {
        document.getElementById("search-results").innerHTML = html;
      })
      .catch(error => console.error("Error fetching posts:", error));
  }

  updatePostsList(html) {
    const postsContainer = document.querySelector("[data-posts-list]");
    postsContainer.innerHTML = html;
  }

}
