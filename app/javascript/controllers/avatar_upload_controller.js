import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["preview", "input"]

  select() {
    this.inputTarget.click()
  }

  preview() {
    const file = this.inputTarget.files[0]
    if (file) {
      const reader = new FileReader()
      reader.onload = (e) => {
        const el = this.previewTarget
        if (el.tagName === "IMG") {
          el.src = e.target.result
        } else {
          const img = document.createElement("img")
          img.src = e.target.result
          img.className = "avatar-preview"
          img.setAttribute("data-avatar-upload-target", "preview")
          el.replaceWith(img)
        }
      }
      reader.readAsDataURL(file)
    }
  }
}
