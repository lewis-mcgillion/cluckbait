import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  toggle() {
    const button = this.element.querySelector(".nav-hamburger")
    const expanded = button.getAttribute("aria-expanded") === "true"

    button.setAttribute("aria-expanded", !expanded)
    button.classList.toggle("active")
    this.menuTarget.classList.toggle("nav-center--open")
  }

  // Close menu when clicking a nav link
  close() {
    const button = this.element.querySelector(".nav-hamburger")
    button.setAttribute("aria-expanded", "false")
    button.classList.remove("active")
    this.menuTarget.classList.remove("nav-center--open")
  }
}
