import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="post-comments"
export default class extends Controller {
  static targets = ["editForm", "displayContent", "replyForm", "commentContainer"]
  activeMenu = null;

  connect() {
    this.checkForAuthor();
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
    const menu = this.element.querySelector(`[data-post-comments-target="miniMenu"][data-comment-id="${commentId}"]`);

    if (menu) {
      menu.classList.toggle('hidden');
      if (!menu.classList.contains('hidden')) {
        this.activeMenu = menu;
        document.addEventListener('click', this.closeMenuOnClickOutside.bind(this), { capture: true });
      } else if (this.activeMenu === menu) {
        document.removeEventListener('click', this.closeMenuOnClickOutside.bind(this), { capture: true });
        this.activeMenu = null;
      }
    }
  }

  closeMenuOnClickOutside(event) {
    if (this.activeMenu && !this.activeMenu.contains(event.target) && !event.target.closest(`[data-action*="post-comments#toggleMenu"]`)) {
      this.activeMenu.classList.add('hidden');
      document.removeEventListener('click', this.closeMenuOnClickOutside.bind(this), { capture: true });
      this.activeMenu = null;
    }
  }


  cancelEdit(event) {
    event.preventDefault();
    event.stopPropagation();
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
