import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["results", "input", "clear"];

  connect() {
    this.toggleClearButton();
    document.addEventListener("click", this.handleClickOutside.bind(this));
  }

  disconnect() {
    document.removeEventListener("click", this.handleClickOutside.bind(this));
  }

  search(event) {
    const query = this.inputTarget.value.trim();
    this.toggleClearButton();

    if (query.length < 2) {
      this.resultsTarget.innerHTML = "";
      this.resultsTarget.classList.add("hidden");
      return;
    }

    fetch(`/admin/users/search?q=${encodeURIComponent(query)}`, {
      headers: { "Accept": "application/json" },
    })
      .then((response) => response.json())
      .then((users) => {
        this.updateResults(users);
      })
      .catch((error) => console.error("Error fetching search results:", error));
  }

  updateResults(users) {
    if (users.length === 0) {
      this.resultsTarget.classList.add("hidden");
      return;
    }

    this.resultsTarget.classList.remove("hidden");
    this.resultsTarget.innerHTML = users
      .map((user) => {
        return `
          <li>
            <a href="/admin/users/${user.id}" class="block px-4 py-2">
              <div class="text-sm text-gray-900">${user.first_name} ${user.last_name} (${user.email})</div>
              <div class="text-xs text-gray-500">ID: ${user.id}</div>
            </a>
          </li>
        `;
      })
      .join("");
  }

  clearSearch() {
    this.inputTarget.value = "";
    this.resultsTarget.innerHTML = "";
    this.resultsTarget.classList.add("hidden");
    this.toggleClearButton();
  }

  toggleClearButton() {
    const clearButton = this.clearTarget;
    if (this.inputTarget.value.length > 0) {
      clearButton.style.visibility = "visible";
    } else {
      clearButton.style.visibility = "hidden";
    }
  }

  handleClickOutside(event) {
    if (
      !this.element.contains(event.target) &&
      !this.resultsTarget.classList.contains("hidden")
    ) {
      this.clearSearch();
    }
  }
}
