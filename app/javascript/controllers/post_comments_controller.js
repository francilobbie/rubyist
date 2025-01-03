import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="post-comments"
export default class extends Controller {
  static targets = ["editForm", "displayContent", "replyForm", "commentContainer", "miniMenu"]

  connect() {
    this.checkForAuthor();
    document.addEventListener("click", this.closeMenuOnClickOutside.bind(this));
  }

  disconnect() {
    document.removeEventListener("click", this.closeMenuOnClickOutside.bind(this));
  }

  checkForAuthor() {
    this.commentContainerTargets.forEach((container) => {
      try {
        const userId = container.dataset.userId;
        const postUserId = container.dataset.postUserId;
        if (userId === postUserId) {
          this.appendAuthorTag(container);
        }
      } catch (error) {
        console.error("Error appending author tag:", error);
      }
    });
  }

  appendAuthorTag(container) {
    const authorTagHtml = `<span class="bg-blue-100 text-blue-800 text-xs font-semibold px-2.5 py-0.5 rounded dark:bg-blue-200 dark:text-blue-800 ml-3">Author</span>`;
    container.querySelector('.text-gray-900').insertAdjacentHTML('beforeend', authorTagHtml);
  }

  toggleEdit(event) {
    event.preventDefault();
    const commentId = event.currentTarget.dataset.commentId;
    const form = this.editFormTargets.find(el => el.dataset.commentId === commentId);
    const content = this.displayContentTargets.find(el => el.dataset.commentId === commentId);
    const commentContainer = this.commentContainerTargets.find(el => el.id === commentId);

    if (form && content && commentContainer) {
      form.classList.toggle("hidden");
      content.classList.toggle("hidden");
      commentContainer.classList.toggle("editing");
    }
  }

  toggleReplyForm(event) {
    event.preventDefault();
    const commentId = event.currentTarget.dataset.commentId;
    const replyForm = this.replyFormTargets.find(el => el.dataset.commentId === commentId);

    if (replyForm) {
      replyForm.classList.toggle("hidden");
    }
  }

  toggleMenu(event) {
    event.preventDefault();
    const commentId = event.currentTarget.dataset.commentId;
    const menu = this.miniMenuTargets.find(el => el.dataset.commentId === commentId);

    if (menu) {
      menu.classList.toggle('hidden');
    }
  }

  closeMenuOnClickOutside(event) {
    this.miniMenuTargets.forEach(menu => {
      if (!menu.classList.contains('hidden') && !menu.contains(event.target) && !event.target.closest(`[data-comment-id="${menu.dataset.commentId}"]`)) {
        menu.classList.add('hidden');
      }
    });
  }

  cancelEdit(event) {
    event.preventDefault();
    this.toggleEdit(event);
  }

  startReply(event) {
    event.preventDefault();
    const commentId = event.currentTarget.dataset.commentId;
    const form = this.replyFormTargets.find(form => form.dataset.commentId === commentId);
    if (form) {
      form.addEventListener('turbo:submit-end', (e) => {
        this.clearForm(e);
      }, { once: true });
      form.classList.remove('hidden');
    }
  }

  clearForm(event) {
    event.preventDefault();
    const form = event.target;
    form.reset();
    form.classList.add('hidden');
  }
}
