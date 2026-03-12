import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["shareableType", "shareableId", "sharePreview", "sharePreviewText", "input"]

  toggleShare() {
    const panel = document.getElementById("share-panel")
    panel.style.display = panel.style.display === "none" ? "block" : "none"
  }

  setShare(type, id, label) {
    this.shareableTypeTarget.value = type
    this.shareableIdTarget.value = id
    this.sharePreviewTarget.style.display = "flex"
    this.sharePreviewTextTarget.textContent = label

    document.getElementById("share-panel").style.display = "none"
  }

  clearShare() {
    this.shareableTypeTarget.value = ""
    this.shareableIdTarget.value = ""
    this.sharePreviewTarget.style.display = "none"
    this.sharePreviewTextTarget.textContent = ""
  }
}
