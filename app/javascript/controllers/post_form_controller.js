// app/javascript/controllers/post_form_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["scheduleOptions"]

  connect() {
    this.toggleScheduleOptions() // Ensure the correct state on page load
  }

  toggleScheduleOptions() {
    const scheduleRadio = document.getElementById("schedule_option")
    if (scheduleRadio.checked) {
      this.scheduleOptionsTarget.classList.remove("hidden")
    } else {
      this.scheduleOptionsTarget.classList.add("hidden")
    }
  }
}
