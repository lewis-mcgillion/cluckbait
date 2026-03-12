import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  dismiss() {
    this.element.remove()
  }

  connect() {
    this.timeout = setTimeout(() => {
      this.element.classList.add("flash-fade")
      setTimeout(() => this.element.remove(), 500)
    }, 5000)
  }

  disconnect() {
    clearTimeout(this.timeout)
  }
}
