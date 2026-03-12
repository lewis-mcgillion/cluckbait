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
      (error) => {
        let message
        switch (error.code) {
          case error.PERMISSION_DENIED:
            message = "Location access was denied. Please allow location access in your browser settings and try again."
            break
          case error.TIMEOUT:
            message = "Location request timed out. Please try again."
            break
          case error.POSITION_UNAVAILABLE:
            message = "Your location could not be determined. Please try again later."
            break
          default:
            message = "Unable to get your location. Please try again."
        }
        alert(message)
        btn.textContent = "📍 Nearest to Me"
        btn.disabled = false
      },
      { enableHighAccuracy: true, timeout: 10000 }
    )
  }
}
