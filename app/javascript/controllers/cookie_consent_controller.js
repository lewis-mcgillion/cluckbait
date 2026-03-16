import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["banner"]

  connect() {
    if (localStorage.getItem("cookie_consent")) {
      this.bannerTarget.remove()
    }
  }

  accept() {
    this.#setConsent("all")
  }

  acceptEssential() {
    this.#setConsent("essential")
  }

  #setConsent(level) {
    localStorage.setItem("cookie_consent", level)
    document.cookie = `cookie_consent=${level}; path=/; max-age=${60 * 60 * 24 * 365}; SameSite=Lax`
    this.bannerTarget.classList.add("cookie-banner-fade")
    setTimeout(() => this.bannerTarget.remove(), 300)
  }
}
