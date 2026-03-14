import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  change() {
    this.element.closest("form").submit()
  }
}
