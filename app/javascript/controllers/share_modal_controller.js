import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="share-modal"
export default class extends Controller {
  static targets = ["closeButton"];

  connect() {
    this.url = this.element.dataset.shareUrl;
  }

  open() {
    // Logic to open the modal goes here
    // For example, you might add a class to make the modal visible
    this.element.classList.add("modal-open");
  }

  close() {
    // Logic to close the modal
    this.element.classList.remove("modal-open");
  }

  copyLink() {
    navigator.clipboard.writeText(this.url).then(() => {
      alert("Link copied to clipboard!");
    });
  }

  shareOnReddit() {
    const redditUrl = `https://www.reddit.com/submit?url=${encodeURIComponent(
      this.url
    )}`;
    window.open(redditUrl, "_blank");
  }

  shareOnFacebook() {
    const facebookUrl = `https://www.facebook.com/sharer/sharer.php?u=${encodeURIComponent(
      this.url
    )}`;
    window.open(facebookUrl, "_blank");
  }

  shareOnLinkedIn() {
    const linkedInUrl = `https://www.linkedin.com/shareArticle?url=${encodeURIComponent(
      this.url
    )}`;
    window.open(linkedInUrl, "_blank");
  }

  sendByEmail() {
    const emailSubject = encodeURIComponent("Check out this article");
    const emailBody = encodeURIComponent(
      `I wanted to share this article with you: ${this.url}`
    );
    const mailtoLink = `mailto:?subject=${emailSubject}&body=${emailBody}`;
    window.location.href = mailtoLink;
  }
}
