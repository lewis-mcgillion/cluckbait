import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

// Subscribes to PresenceChannel and updates online indicators for friends.
// Attach to an element with data-presence-user-id-value="<user_id>".
export default class extends Controller {
  static values = { userId: Number }

  connect() {
    this.subscription = consumer.subscriptions.create("PresenceChannel", {
      connected: () => this.handleConnected(),
      disconnected: () => this.handleDisconnected(),
      rejected: () => this.handleRejected(),
      received: (data) => this.handlePresence(data)
    })
  }

  disconnect() {
    if (this.subscription) {
      this.subscription.unsubscribe()
    }
  }

  handleConnected() {
    // Connection established — presence tracking is active
  }

  handleDisconnected() {
    // Connection lost — mark all presence indicators as unknown/offline
    document.querySelectorAll(".presence-online").forEach((dot) => {
      dot.classList.remove("presence-online")
    })
  }

  handleRejected() {
    // Subscription rejected by server
    console.warn("PresenceChannel subscription was rejected")
  }

  handlePresence(data) {
    if (data.type !== "presence") return

    const dot = document.getElementById(`presence-${data.user_id}`)
    if (!dot) return

    if (data.online) {
      dot.classList.add("presence-online")
    } else {
      dot.classList.remove("presence-online")
    }
  }
}
