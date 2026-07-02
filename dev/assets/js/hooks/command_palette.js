const CommandPalette = {
  mounted() {
    this._keyHandler = (e) => {
      if ((e.metaKey || e.ctrlKey) && e.key === "k") {
        e.preventDefault()
        this.pushEventTo(this.el, "open", {})
        setTimeout(() => {
          const input = document.getElementById(
            this.el.id.replace("-listener", "-input")
          )
          if (input) input.focus()
        }, 50)
      }
      if (e.key === "Escape") {
        this.pushEventTo(this.el, "close", {})
      }
    }
    document.addEventListener("keydown", this._keyHandler)
  },

  destroyed() {
    document.removeEventListener("keydown", this._keyHandler)
  }
}

export default CommandPalette
