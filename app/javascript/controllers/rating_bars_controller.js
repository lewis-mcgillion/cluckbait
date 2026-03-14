import { Controller } from "@hotwired/stimulus"

// Sets the width of rating bar fills from data-width attributes
// to avoid CSP inline style violations.
export default class extends Controller {
  connect() {
    this.element.querySelectorAll("[data-width]").forEach((el) => {
      el.style.width = `${el.dataset.width}%`
    })
  }
}
