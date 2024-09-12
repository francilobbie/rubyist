import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["stripeToken"];

  async connect() {
    const stripeKey = this.element.dataset.stripePublishableKey;
    this.stripe = Stripe(stripeKey);

    this.elements = this.stripe.elements();

    // Create an instance of the card Element
    this.card = this.elements.create("card");
    this.card.mount("#card-element");

    // Handle real-time validation errors from the card Element
    this.card.on("change", (event) => {
      const displayError = document.getElementById("card-errors");
      if (event.error) {
        displayError.textContent = event.error.message;
      } else {
        displayError.textContent = "";
      }
    });
  }

  async submit(event) {
    event.preventDefault();

    // Correctly target the form element for submission
    const form = this.element.querySelector("form"); // Locate the form element

    const { token, error } = await this.stripe.createToken(this.card);

    if (error) {
      // Display error in the UI
      const errorElement = document.getElementById("card-errors");
      errorElement.textContent = error.message;
    } else {
      // Send the token to your server
      this.stripeTokenTarget.value = token.id;
      form.submit(); // Submit the form
    }
  }
}
