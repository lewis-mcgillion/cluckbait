import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "searchInput"]
  static values = {
    shops: { type: Array, default: [] }
  }

  connect() {
    this.markers = []
    this.abortController = null
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

  escapeHtml(str) {
    const div = document.createElement("div")
    div.textContent = str
    return div.innerHTML
  }

  loadShops(params = {}) {
    if (this.abortController) this.abortController.abort()
    this.abortController = new AbortController()

    const queryString = new URLSearchParams(params).toString()
    fetch("/api/shops?" + queryString, { signal: this.abortController.signal })
      .then(r => {
        if (!r.ok) throw new Error(`Server error: ${r.status} ${r.statusText}`)
        return r.json()
      })
      .then(shops => {
        this.clearMarkers()
        shops.forEach(shop => {
          const stars = "★".repeat(Math.round(shop.average_rating)) + "☆".repeat(5 - Math.round(shop.average_rating))
          const name = this.escapeHtml(shop.name)
          const address = this.escapeHtml(shop.address)
          const url = encodeURI(shop.url)
          const marker = L.marker([shop.latitude, shop.longitude], { icon: this.chickenIcon })
            .addTo(this.map)
            .bindPopup(`
              <div class="map-popup">
                <h3><a href="${url}">${name}</a></h3>
                <p class="popup-address">${address}</p>
                <div class="popup-rating">
                  <span class="popup-stars">${stars}</span>
                  <span class="popup-count">${shop.average_rating} (${shop.reviews_count} reviews)</span>
                </div>
                <a href="${url}" class="popup-link">View Reviews →</a>
              </div>
            `)
          this.markers.push(marker)
        })

        if (shops.length > 0 && params.search) {
          const group = new L.featureGroup(this.markers)
          this.map.fitBounds(group.getBounds().pad(0.1))
        }
      })
      .catch(error => {
        if (error.name === "AbortError") return
        console.error("Failed to load shops:", error)
        alert("Unable to load chicken shops. Please try again later.")
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
      (error) => {
        let message
        switch (error.code) {
          case error.PERMISSION_DENIED:
            message = "Location access was denied. Please allow location access in your browser settings."
            break
          case error.TIMEOUT:
            message = "Location request timed out. Please try again."
            break
          case error.POSITION_UNAVAILABLE:
            message = "Your location could not be determined. Please search manually."
            break
          default:
            message = "Unable to get your location. Please search manually."
        }
        alert(message)
        button.classList.remove("loading")
      }
    )
  }

  disconnect() {
    if (this.abortController) this.abortController.abort()
    if (this.map) {
      this.map.remove()
    }
  }
}
