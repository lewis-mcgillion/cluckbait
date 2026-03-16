import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["banner"]

  connect() {
    if (localStorage.getItem("cookie_consent")) {
      this.bannerTarget.remove()
    }
  }

  accept() {
    localStorage.setItem("cookie_consent", "all")
    this.bannerTarget.classList.add("cookie-banner-fade")
    setTimeout(() => this.bannerTarget.remove(), 300)
  }

  acceptEssential() {
    localStorage.setItem("cookie_consent", "essential")
    this.bannerTarget.classList.add("cookie-banner-fade")
    setTimeout(() => this.bannerTarget.remove(), 300)
  }
}
