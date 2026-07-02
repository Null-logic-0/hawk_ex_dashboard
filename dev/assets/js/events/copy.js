export function setupCopy() {
  window.addEventListener("hawk_ex:copy", (e) => {
    const text = e.detail?.text || e.target.innerText

    navigator.clipboard.writeText(text).then(() => {
      const btn = e.target.closest("button")
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
}
