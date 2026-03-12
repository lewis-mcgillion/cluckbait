import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"]

  toggle(event) {
    const button = event.currentTarget
    button.classList.add("wishlist-loading")
    button.disabled = true
  }
}
