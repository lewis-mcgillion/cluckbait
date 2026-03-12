import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "shopsPane", "reviewsPane", "shopSearch", "shopResults"]

  close() {
    this.element.closest("#share-panel").style.display = "none"
  }

  switchTab(event) {
    const tab = event.currentTarget.dataset.tab

    this.element.querySelectorAll(".share-tab").forEach(t => t.classList.remove("active"))
    event.currentTarget.classList.add("active")

    this.element.querySelectorAll(".share-tab-pane").forEach(p => p.classList.remove("active"))
    this.element.querySelector(`.share-tab-pane[data-tab="${tab}"]`).classList.add("active")
  }

  async searchShops() {
    const query = this.shopSearchTarget.value.trim()
    if (query.length < 2) {
      this.shopResultsTarget.innerHTML = '<p class="text-muted share-hint">Type to search for a shop to share</p>'
      return
    }

    try {
      const response = await fetch(`/api/shops?search=${encodeURIComponent(query)}`)
      const shops = await response.json()

      if (shops.length === 0) {
        this.shopResultsTarget.innerHTML = '<p class="text-muted share-hint">No shops found</p>'
        return
      }

      this.shopResultsTarget.innerHTML = shops.slice(0, 10).map(shop => `
        <button type="button" class="share-item"
                data-action="click->share-panel#selectShop"
                data-shareable-type="ChickenShop"
                data-shareable-id="${shop.id}"
                data-shareable-label="${shop.name}">
          <span class="share-item-icon">🍗</span>
          <div class="share-item-info">
            <span class="share-item-title">${shop.name}</span>
            <span class="share-item-meta">${shop.city} · ${shop.average_rating} ★</span>
          </div>
        </button>
      `).join("")
    } catch (e) {
      this.shopResultsTarget.innerHTML = '<p class="text-muted share-hint">Error searching shops</p>'
    }
  }

  selectShop(event) {
    const btn = event.currentTarget
    const type = btn.dataset.shareableType
    const id = btn.dataset.shareableId
    const label = btn.dataset.shareableLabel

    const form = document.querySelector('[data-controller="message-form"]')
    const formController = this.application.getControllerForElementAndIdentifier(form, "message-form")
    if (formController) {
      formController.setShare(type, id, `🍗 ${label}`)
    }
  }

  selectItem(event) {
    const btn = event.currentTarget
    const type = btn.dataset.shareableType
    const id = btn.dataset.shareableId
    const title = btn.querySelector(".share-item-title").textContent
    const icon = type === "Review" ? "⭐" : "🍗"

    const form = document.querySelector('[data-controller="message-form"]')
    const formController = this.application.getControllerForElementAndIdentifier(form, "message-form")
    if (formController) {
      formController.setShare(type, id, `${icon} ${title}`)
    }
  }
}
