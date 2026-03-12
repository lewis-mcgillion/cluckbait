import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    lat: Number,
    lng: Number,
    name: String
  }

  connect() {
    this.map = L.map(this.element).setView([this.latValue, this.lngValue], 15)
    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      attribution: "&copy; OpenStreetMap",
      maxZoom: 19
    }).addTo(this.map)

    const chickenIcon = L.divIcon({
      className: "chicken-marker",
      html: '<div class="marker-pin">🍗</div>',
      iconSize: [40, 40],
      iconAnchor: [20, 40],
      popupAnchor: [0, -40]
    })

    L.marker([this.latValue, this.lngValue], { icon: chickenIcon })
      .addTo(this.map)
      .bindPopup(this.nameValue)
  }

  disconnect() {
    if (this.map) this.map.remove()
  }
}
