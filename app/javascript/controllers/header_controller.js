import { Controller } from "@hotwired/stimulus"
import { enter, leave } from "el-transition"

export default class extends Controller {
  static targets = ["openUserMenu", "openMobileUserMenu", "menu"]

  connect() {
    this.openUserMenuTarget.addEventListener("click", () => this.toggleUserMenu());
    this.openMobileUserMenuTarget.addEventListener("click", () => this.toggleMobileMenu());
  }

  toggleUserMenu() {
    // Assuming 'menu-dropdown-items' is the ID for the user menu
    const userMenu = document.getElementById('menu-dropdown-items');
    if (userMenu.classList.contains('hidden')) {
      enter(userMenu);
    } else {
      leave(userMenu);
    }
  }

  toggleMobileMenu() {
    // Toggle mobile menu visibility
    const mobileMenu = document.getElementById('mobile-menu-dropdown-items');
    if (this.menuTarget.classList.contains('hidden')) {
      enter(mobileMenu);
    } else {
      leave(mobileMenu);
    }
  }
}
