import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "sortField", "latField", "lngField", "distanceBtn"]

  sortBy(event) {
    const value = event.currentTarget.dataset.sortValue
    this.sortFieldTarget.value = value
    this.latFieldTarget.value = ""
    this.lngFieldTarget.value = ""
    this.formTarget.requestSubmit()
  }

  sortByDistance() {
    if (!navigator.geolocation) {
      alert("Geolocation is not supported by your browser.")
      return
    }

    const btn = this.distanceBtnTarget
    btn.textContent = "📍 Locating..."
    btn.disabled = true

    navigator.geolocation.getCurrentPosition(
      (position) => {
        this.sortFieldTarget.value = "distance"
        this.latFieldTarget.value = position.coords.latitude
        this.lngFieldTarget.value = position.coords.longitude
        this.formTarget.requestSubmit()
      },
      () => {
        alert("Unable to get your location. Please allow location access and try again.")
        btn.textContent = "📍 Nearest to Me"
        btn.disabled = false
      },
      { enableHighAccuracy: true, timeout: 10000 }
    )
  }
}
