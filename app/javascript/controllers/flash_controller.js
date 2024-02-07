import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["notice", "alert"];

  connect() {
    if (this.hasNoticeTarget || this.hasAlertTarget) {
      setTimeout(() => {
        this.show();
      }, 100); // small delay to allow for CSS transition

      setTimeout(() => {
        this.close();
      }, 3000); // 3000 milliseconds = 3 seconds
    }
  }

  show() {
    if (this.hasNoticeTarget) {
      this.noticeTarget.classList.add('show');
    }
    if (this.hasAlertTarget) {
      this.alertTarget.classList.add('show');
    }
  }

  close() {
    if (this.hasNoticeTarget) {
      this.noticeTarget.classList.remove('show');
    }
    if (this.hasAlertTarget) {
      this.alertTarget.classList.remove('show');
    }

    setTimeout(() => {
      if (this.hasNoticeTarget) {
        this.noticeTarget.remove();
      }
      if (this.hasAlertTarget) {
        this.alertTarget.remove();
      }
    }, 500); // match the CSS transition duration
  }
}
