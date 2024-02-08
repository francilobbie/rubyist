// app/javascript/controllers/modal_controller.js
import { Controller } from "@hotwired/stimulus";
import { enter, leave } from "el-transition";

export default class extends Controller {
  static targets = [ "closeButton" ]

  connect() {
    window.addEventListener('show-modal', this.handleShowModal.bind(this));
    window.addEventListener('close-modal', this.handleCloseModal.bind(this)); // Listen for close-modal event
    document.addEventListener('keydown', this.handleKeyDown.bind(this)); // Add this line
    document.getElementById(`modal-${this.element.dataset.modalTriggerId}-wrapper`).addEventListener("click", (event) => {
      this.closeModal(event, this.element.dataset.modalTriggerId)});
    this.closeButtonTarget.addEventListener("click", () => {
      leave(document.getElementById(`modal-${this.element.dataset.modalTriggerId}-wrapper`))
      leave(document.getElementById(`modal-${this.element.dataset.modalTriggerId}-backdrop`))
      leave(document.getElementById(`modal-${this.element.dataset.modalTriggerId}-panel`))
    });
  }

  disconnect() {
    window.removeEventListener('show-modal', this.handleShowModal.bind(this));
    window.removeEventListener('close-modal', this.handleCloseModal.bind(this)); // Stop listening for close-modal event
    document.removeEventListener('keydown', this.handleKeyDown.bind(this)); // Add this line
  }

  handleShowModal(event) {
    const { triggerId } = event.detail;
    if (triggerId === "search-form") {
      this.showModal();
    }
  }

  handleCloseModal(event) {
    const { triggerId } = event.detail;
    if (triggerId === "search-form") {
      this.closeModal();
    }
  }

  handleKeyDown(event) {
    if (event.key === "Escape") {
      this.closeModalDirectly(); // Changed method name to avoid confusion
    }
  }

  showModal() {
    // Assuming modal elements have correct IDs
    const modalPanel = document.getElementById(`modal-${this.element.dataset.modalTriggerId}-panel`);
    const backdrop = document.getElementById(`modal-${this.element.dataset.modalTriggerId}-backdrop`);
    const wrapper = document.getElementById(`modal-${this.element.dataset.modalTriggerId}-wrapper`);
    enter(wrapper);
    enter(backdrop);
    enter(modalPanel);

    if (modalPanel.id === 'modal-search-form-panel') {
      // Modify the modal's size classes when the "share flat" content is present
      modalPanel.classList.add('sm:mb-96'); // This will resize the modal
      modalPanel.classList.remove('sm:my-8'); // Remove this if it exists
    }
  }

  closeModal(event, triggerId) {
    const modalPanelClicked = document.getElementById(`modal-${triggerId}-panel`).contains(event.target)
    if (!modalPanelClicked && event.target.id !== triggerId) {
    leave(document.getElementById(`modal-${triggerId}-wrapper`))
    leave(document.getElementById(`modal-${triggerId}-backdrop`))
    leave(document.getElementById(`modal-${triggerId}-panel`))
    }
  }

  closeModalDirectly() {
    // Use this method to close the modal directly without needing an event or triggerId
    leave(document.getElementById(`modal-${this.element.dataset.modalTriggerId}-wrapper`));
    leave(document.getElementById(`modal-${this.element.dataset.modalTriggerId}-backdrop`));
    leave(document.getElementById(`modal-${this.element.dataset.modalTriggerId}-panel`));
  }
}
