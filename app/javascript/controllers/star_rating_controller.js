import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["star", "input"]

  connect() {
    this.updateStars()
  }

  select(event) {
    const value = parseInt(event.currentTarget.dataset.value)
    this.inputTarget.value = value
    this.updateStars()
  }

  hover(event) {
    const value = parseInt(event.currentTarget.dataset.value)
    this.starTargets.forEach((star, i) => {
      star.classList.toggle("hover", i < value)
    })
  }

  unhover() {
    this.starTargets.forEach(star => star.classList.remove("hover"))
  }

  updateStars() {
    const value = parseInt(this.inputTarget.value) || 0
    this.starTargets.forEach((star, i) => {
      star.classList.toggle("active", i < value)
    })
  }
}
