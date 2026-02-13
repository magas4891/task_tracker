import { Controller } from "@hotwired/stimulus"

// Resize a fixed right panel by dragging its left edge.
export default class extends Controller {
  static values = {
    minWidth: { type: Number, default: 280 },
    maxWidth: { type: Number, default: 900 }
  }

  startResize(event) {
    if (event.button !== 0) return
    event.preventDefault()
    this.initialX = event.clientX
    this.initialWidth = this.element.offsetWidth
    this.element.classList.add("task-panel-wrapper--resizing")
    this.boundResize = this.resize.bind(this)
    this.boundStop = this.stopResize.bind(this)
    document.addEventListener("mousemove", this.boundResize)
    document.addEventListener("mouseup", this.boundStop)
    document.body.style.cursor = "col-resize"
    document.body.style.userSelect = "none"
  }

  stopResize() {
    document.removeEventListener("mousemove", this.boundResize)
    document.removeEventListener("mouseup", this.boundStop)
    document.body.style.cursor = ""
    document.body.style.userSelect = ""
    this.element.classList.remove("task-panel-wrapper--resizing")
  }

  resize(event) {
    const dx = this.initialX - event.clientX
    let w = this.initialWidth + dx
    w = Math.max(this.minWidthValue, Math.min(this.maxWidthValue, w))
    this.element.style.width = `${w}px`
  }
}
