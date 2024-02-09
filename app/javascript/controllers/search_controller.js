import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search"
export default class extends Controller {
  static targets = ["input", "form", "list", "ajax", "results"]

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

    // Clear the input field
    if (this.hasInputTarget) {
      this.inputTarget.value = '';
    }

    // Optionally, clear the results
    if (this.hasResultsTarget) {
      this.resultsTarget.innerHTML = '';
    }
  }


  search() {
    const query = this.inputTarget.value;
    const url = `/posts?query=${encodeURIComponent(query)}&ajax=true`;

    fetch(url, {
      headers: {
        "X-Requested-With": "XMLHttpRequest",
        "Accept": "text/javascript, application/javascript, application/ecmascript, application/x-ecmascript",
        "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8"
      }
    })
    .then(response => response.text())
    .then(html => {
      this.resultsTarget.innerHTML = html;
    })
    .catch(error => console.error("Error fetching search results:", error));
  }
}
