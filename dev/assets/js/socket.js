import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import CommandPalette from "./hooks/command_palette"

const hooks = {
  CommandPalette
}

const csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content")

const liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks
})

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

export default liveSocket
