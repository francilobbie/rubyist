import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="ban-countdown"
export default class extends Controller {
  static values = { time: Number };

  connect() {
    console.log("Ban countdown controller connected");
    this.updateTime();
    this.timer = setInterval(() => this.updateTime(), 1000);
  }

  updateTime() {
    const endTime = new Date(this.timeValue * 1000); // Convert Unix timestamp to JS Date object
    const now = new Date();
    const distance = endTime - now;

    if (distance < 0) {
      clearInterval(this.timer);
      this.element.innerHTML = "EXPIRED"; // Notice the change from this.timeTarget to this.element
      return;
    }

    const days = Math.floor(distance / (1000 * 60 * 60 * 24));
    const hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
    const minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
    const seconds = Math.floor((distance % (1000 * 60)) / 1000);

    this.element.innerHTML = `${days}d ${hours}h ${minutes}m ${seconds}s`; // Changed to this.element
  }

  disconnect() {
    if (this.timer) {
      clearInterval(this.timer);
    }
  }
}
