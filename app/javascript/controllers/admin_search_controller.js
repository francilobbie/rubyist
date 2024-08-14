// app/javascript/controllers/admin_user_search_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results"]


  connect() {
    console.log("AdminUserSearchController connected") // Add this line
  }

  search() {
    const query = this.inputTarget.value.trim()

    if (query.length < 2) {
      this.resultsTarget.innerHTML = ""
      this.resultsTarget.classList.add("hidden")
      return
    }

    const url = `/admin/users/search?q=${encodeURIComponent(query)}`

    fetch(url, {
      headers: {
        "X-Requested-With": "XMLHttpRequest",
        "Accept": "application/json",
      }
    })
    .then(response => response.json())
    .then(data => {
      this.updateResults(data)
    })
    .catch(error => console.error("Error fetching search results:", error))
  }

  updateResults(users) {
    if (users.length === 0) {
      this.resultsTarget.innerHTML = "<li class='p-2 text-gray-500'>No users found</li>"
      this.resultsTarget.classList.remove("hidden")
      return
    }

    this.resultsTarget.innerHTML = users.map(user => `
      <li class="p-2 hover:bg-gray-100">
        <a href="/admin/users/${user.id}" class="block text-gray-900">
          <div class="font-semibold">${user.first_name} ${user.last_name} (${user.email})</div>
          <div class="text-sm text-gray-500">ID: ${user.id}</div>
        </a>
      </li>
    `).join("")
    this.resultsTarget.classList.remove("hidden")
  }
}
