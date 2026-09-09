import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="quickfind"
export default class extends Controller {
  connect() {
    console.log("quickfind controller connected")
  }

  search(_event) {
    console.log("search triggered")
    clearTimeout(this.timeout);
    this.timeout = setTimeout(() => {
      this.element.requestSubmit();
    }, 300);
  }
}
