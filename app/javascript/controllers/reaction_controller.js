import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "count"]

  toggle(event) {
    const button = event.currentTarget
    const isActive = button.classList.contains("reaction-btn--active") ||
                     button.classList.contains("helpful-btn--active")

    // Optimistic toggle of active class
    if (button.classList.contains("reaction-btn") || button.classList.contains("reaction-btn--active")) {
      button.classList.toggle("reaction-btn--active")
    }
    if (button.classList.contains("helpful-btn") || button.classList.contains("helpful-btn--active")) {
      button.classList.toggle("helpful-btn--active")
    }

    // Animate count change
    const countEl = button.querySelector("[data-reaction-target='count']")
    if (countEl) {
      countEl.classList.add("reaction-count--animating")
      setTimeout(() => countEl.classList.remove("reaction-count--animating"), 300)
    }
  }
}
