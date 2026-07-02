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

window.addEventListener("hawk_ex:copy", (e) => {
  const text = e.detail.text || e.target.innerText

  navigator.clipboard.writeText(text).then(() => {
    const btn = e.target.closest("button") ||
      document.querySelector(`[phx-click*="hawk_ex:copy"]`)

    if (btn) {
      const orig = btn.innerHTML
      btn.innerHTML = "✓"
      setTimeout(() => { btn.innerHTML = orig }, 1500)
    }
  }).catch(() => {
    const ta = document.createElement("textarea")
    ta.value = text
    ta.style.position = "fixed"
    ta.style.opacity = "0"
    document.body.appendChild(ta)
    ta.select()
    document.execCommand("copy")
    document.body.removeChild(ta)
  })
})

liveSocket.connect()
window.liveSocket = liveSocket
