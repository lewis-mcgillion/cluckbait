import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

// Handles typing indicators in conversations.
// Attach to a parent element that wraps both the indicator and message form.
// Uses a "indicator" target for the typing indicator display element.
export default class extends Controller {
  static targets = ["indicator"]
  static values = { conversationId: Number, userId: Number }

  connect() {
    this.typingTimeout = null

    this.subscription = consumer.subscriptions.create(
      { channel: "TypingChannel", conversation_id: this.conversationIdValue },
      {
        received: (data) => this.handleTyping(data)
      }
    )
  }

  disconnect() {
    if (this.subscription) {
      this.subscription.unsubscribe()
    }
    if (this.typingTimeout) {
      clearTimeout(this.typingTimeout)
    }
  }

  // Called from the message form's input event
  onInput() {
    if (!this.subscription) return

    this.subscription.perform("typing", { typing: true })

    if (this.typingTimeout) clearTimeout(this.typingTimeout)

    this.typingTimeout = setTimeout(() => {
      this.subscription.perform("typing", { typing: false })
    }, 2000)
  }

  handleTyping(data) {
    if (data.type !== "typing") return
    if (data.user_id === this.userIdValue) return
    if (!this.hasIndicatorTarget) return

    this.indicatorTarget.style.display = data.typing ? "flex" : "none"
  }
}
