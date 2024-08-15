import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="password-toggle"
export default class extends Controller {
  static targets = ["password", "toggleIcon"];

  toggle() {
    this.passwordTargets.forEach((passwordField) => {
      const type = passwordField.getAttribute("type") === "password" ? "text" : "password";
      passwordField.setAttribute("type", type);

      // Toggle visibility of the icons
      this.toggleIconTargets.forEach((icon) => {
        icon.classList.toggle("hidden", icon.dataset.iconType !== (type === "password" ? "show" : "hide"));
      });
    });
  }

  connect() {
    console.log("Connected to password toggle controller");
  }
}
