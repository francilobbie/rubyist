import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dropdown"
export default class extends Controller {
  static targets = ["display", "list", "selected", "item"]

  connect() {
    this.updateDisplay(); // Initial display update based on selected roles
  }

  toggle() {
    this.listTarget.classList.toggle('hidden');
  }

  select(event) {
    const roleId = event.currentTarget.dataset.roleId;
    this.selectedTarget.value = roleId; // Change the hidden field value
    this.updateDisplay(); // Update the displayed roles
    this.toggle(); // Close the dropdown
  }

  selectNoRole() {
    this.selectedTarget.value = ''; // Reset the hidden field value
    this.updateDisplay(); // Update the displayed roles
    this.toggle(); // Close the dropdown
  }

  updateDisplay() {
    const selectedRoleId = this.selectedTarget.value;
    const role = this.itemTargets.find(item => item.dataset.roleId === selectedRoleId);
    this.displayTarget.textContent = role ? role.textContent : 'No Role';
  }

  clickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.listTarget.classList.add('hidden');
    }
  }
}
