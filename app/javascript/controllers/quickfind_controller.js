import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="quickfind"
export default class extends Controller {
  connect() { }

  search(_event) {
    clearTimeout(this.timeout);
    this.timeout = setTimeout(() => {
      this.element.requestSubmit();
    }, 100);
  }
}
