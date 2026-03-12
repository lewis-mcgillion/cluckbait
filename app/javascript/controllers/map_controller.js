import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "searchInput"]
  static values = {
    shops: { type: Array, default: [] }
  }

  connect() {
    this.markers = []
    this.initMap()
    this.loadShops()
  }

  initMap() {
    this.map = L.map(this.containerTarget).setView([53.5, -2.5], 6)
    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>',
      maxZoom: 19
    }).addTo(this.map)
  }

  get chickenIcon() {
    return L.divIcon({
      className: "chicken-marker",
      html: '<div class="marker-pin">🍗</div>',
      iconSize: [40, 40],
      iconAnchor: [20, 40],
      popupAnchor: [0, -40]
    })
  }

  clearMarkers() {
    this.markers.forEach(m => this.map.removeLayer(m))
    this.markers = []
  }

  loadShops(params = {}) {
    const queryString = new URLSearchParams(params).toString()
    fetch("/api/shops?" + queryString)
      .then(r => r.json())
      .then(shops => {
        this.clearMarkers()
        shops.forEach(shop => {
          const stars = "★".repeat(Math.round(shop.average_rating)) + "☆".repeat(5 - Math.round(shop.average_rating))
          const marker = L.marker([shop.latitude, shop.longitude], { icon: this.chickenIcon })
            .addTo(this.map)
            .bindPopup(`
              <div class="map-popup">
                <h3><a href="${shop.url}">${shop.name}</a></h3>
                <p class="popup-address">${shop.address}</p>
                <div class="popup-rating">
                  <span class="popup-stars">${stars}</span>
                  <span class="popup-count">${shop.average_rating} (${shop.reviews_count} reviews)</span>
                </div>
                <a href="${shop.url}" class="popup-link">View Reviews →</a>
              </div>
            `)
          this.markers.push(marker)
        })

        if (shops.length > 0 && params.search) {
          const group = new L.featureGroup(this.markers)
          this.map.fitBounds(group.getBounds().pad(0.1))
        }
      })
  }

  search() {
    clearTimeout(this.searchTimeout)
    this.searchTimeout = setTimeout(() => {
      this.loadShops({ search: this.searchInputTarget.value })
    }, 400)
  }

  locate() {
    if (!navigator.geolocation) return

    const button = event.currentTarget
    button.classList.add("loading")

    navigator.geolocation.getCurrentPosition(
      (position) => {
        const lat = position.coords.latitude
        const lng = position.coords.longitude
        this.map.setView([lat, lng], 12)
        this.loadShops({ lat, lng })

        L.marker([lat, lng], {
          icon: L.divIcon({
            className: "user-marker",
            html: '<div class="user-pin">📍</div>',
            iconSize: [30, 30],
            iconAnchor: [15, 30]
          })
        }).addTo(this.map).bindPopup("You are here!").openPopup()

        button.classList.remove("loading")
      },
      () => {
        alert("Unable to get your location. Please search manually.")
        button.classList.remove("loading")
      }
    )
  }

  disconnect() {
    if (this.map) {
      this.map.remove()
    }
  }
}
