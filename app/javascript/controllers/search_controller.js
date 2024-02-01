import { Controller } from "@hotwired/stimulus"


// Connects to data-controller="search"
export default class extends Controller {
  static targets = [ "input", "form", "list" ]

  connect() {
    this.handleKeyDown = this.handleKeyDown.bind(this);
    document.addEventListener('keydown', this.handleKeyDown, true);
    console.log(this.formTarget);
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

  perform(event) {
    event.preventDefault();
    const url = `${this.formTarget.action}?query=${encodeURIComponent(this.inputTarget.value)}&ajax=true`;
    fetch(url, {
      headers: {
        "Accept": "text/html, application/xhtml+xml"
      }
    })
    .then(response => response.text())
    .then(html => {
      this.updatePostsList(html);
    })
    .catch(error => console.error("Error fetching posts:", error));
  }


  updatePostsList(html) {
    const postsContainer = document.querySelector("[data-posts-list]");
    postsContainer.innerHTML = html;
  }

}
