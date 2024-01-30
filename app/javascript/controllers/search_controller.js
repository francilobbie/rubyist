import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search"
export default class extends Controller {
  static targets = [ "input" ]
  connect() {
    console.log("Hello, Stimulus!", this.element)
  }
}
