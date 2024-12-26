import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    // Iterate over all <pre> elements and wrap them with a container that includes the copy button
    this.element.querySelectorAll("pre").forEach((block) => {
      this.wrapWithCopyButton(block);
    });
  }

  wrapWithCopyButton(block) {
    // Create a wrapper div to hold both the <pre> block and the copy button
    const wrapper = document.createElement("div");
    wrapper.className = "relative mb-4";

    // Create the copy button
    const button = document.createElement("button");
    button.innerText = "Copier le code";
    button.className = "copy-button absolute bottom-2 right-2 bg-gray-800 text-white text-xs px-2 py-1 rounded";

    // Insert the button as a sibling of the <pre> block
    wrapper.appendChild(block.cloneNode(true));
    wrapper.appendChild(button);

    // Replace the <pre> block with the wrapper div in the DOM
    block.parentNode.replaceChild(wrapper, block);

    // Add copy functionality to the button
    button.addEventListener("click", () => {
      // Extract the text from the <code> element inside the <pre> block
      const code = wrapper.querySelector("pre")?.textContent || block.textContent;

      navigator.clipboard.writeText(code)
        .then(() => {
          button.innerText = "Copié!";
          setTimeout(() => { button.innerText = "Copier le code"; }, 2000);
        })
        .catch(() => {
          button.innerText = "Erreur!";
        });
    });
  }
}
