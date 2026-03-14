import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "latitude", "longitude", "coordinates"]

  connect() {
    this.marker = null
    this.initMap()
  }

  initMap() {
    this.map = L.map(this.containerTarget).setView([53.5, -2.5], 6)
    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>',
      maxZoom: 19
    }).addTo(this.map)

    this.map.on("click", (e) => this.placeMarker(e.latlng))

    // If lat/lng already set (e.g. validation re-render), place the marker
    const lat = parseFloat(this.latitudeTarget.value)
    const lng = parseFloat(this.longitudeTarget.value)
    if (lat && lng) {
      this.placeMarker(L.latLng(lat, lng))
      this.map.setView([lat, lng], 14)
    }
  }

  get chickenIcon() {
    return L.divIcon({
      className: "chicken-marker",
      html: '<div class="marker-pin">🍗</div>',
      iconSize: [40, 40],
      iconAnchor: [20, 40]
    })
  }

  placeMarker(latlng) {
    if (this.marker) {
      this.marker.setLatLng(latlng)
    } else {
      this.marker = L.marker(latlng, {
        icon: this.chickenIcon,
        draggable: true
      }).addTo(this.map)

      this.marker.on("dragend", () => {
        this.updateCoordinates(this.marker.getLatLng())
      })
    }
    this.updateCoordinates(latlng)
  }

  updateCoordinates(latlng) {
    const lat = latlng.lat.toFixed(6)
    const lng = latlng.lng.toFixed(6)
    this.latitudeTarget.value = lat
    this.longitudeTarget.value = lng
    this.coordinatesTarget.textContent = `${lat}, ${lng}`
    this.coordinatesTarget.classList.add("has-value")
  }

  locate() {
    if (!navigator.geolocation) return

    const button = event.currentTarget
    button.classList.add("loading")
    button.disabled = true

    navigator.geolocation.getCurrentPosition(
      (position) => {
        const latlng = L.latLng(position.coords.latitude, position.coords.longitude)
        this.map.setView(latlng, 14)
        this.placeMarker(latlng)
        button.classList.remove("loading")
        button.disabled = false
      },
      () => {
        alert("Unable to get your location. Click the map to set the shop location.")
        button.classList.remove("loading")
        button.disabled = false
      },
      { enableHighAccuracy: true, timeout: 10000 }
    )
  }

  disconnect() {
    if (this.map) this.map.remove()
  }
}
