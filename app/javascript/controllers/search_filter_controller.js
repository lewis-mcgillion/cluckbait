import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "filtersForm", "filtersPanel", "toggleBtn", "ratingMin", "ratingMax", "sortField"]

  connect() {
    this.debounceTimer = null
  }

  toggleFilters() {
    if (this.hasFiltersPanelTarget) {
      this.filtersPanelTarget.classList.toggle("advanced-filters-panel--open")
    }
  }

  setRating(event) {
    event.preventDefault()
    const value = event.currentTarget.dataset.value
    if (this.hasRatingMinTarget) {
      this.ratingMinTarget.value = value
    }

    // Update active states
    event.currentTarget.closest(".filter-rating-buttons").querySelectorAll(".filter-chip").forEach(btn => {
      btn.classList.remove("filter-chip--active")
    })
    event.currentTarget.classList.add("filter-chip--active")

    this.submitFilters()
  }

  submitFilters() {
    if (this.hasFiltersFormTarget) {
      this.filtersFormTarget.requestSubmit()
    }
  }

  debounceSubmit() {
    clearTimeout(this.debounceTimer)
    this.debounceTimer = setTimeout(() => {
      if (this.hasFormTarget) {
        this.formTarget.requestSubmit()
      }
    }, 400)
  }

  disconnect() {
    clearTimeout(this.debounceTimer)
  }
}
