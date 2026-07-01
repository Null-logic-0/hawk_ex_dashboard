import "phoenix_html"
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

let liveSocket = new LiveSocket("/live", Socket, { params: { _csrf_token: csrfToken } })

// Connection state indicator for Events page
liveSocket.getSocket().onOpen(() => {
  document.querySelectorAll("[data-connection-status]").forEach(el => {
    el.dataset.connectionStatus = "connected"
  })
})

liveSocket.getSocket().onClose(() => {
  document.querySelectorAll("[data-connection-status]").forEach(el => {
    el.dataset.connectionStatus = "disconnected"
  })
})

liveSocket.connect()
window.liveSocket = liveSocket
