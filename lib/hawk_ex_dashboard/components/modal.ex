defmodule HawkExDashboard.Modal do
  @moduledoc false
  use Phoenix.Component

  attr(:id, :string, required: true)
  attr(:show, :boolean, default: false)
  attr(:title, :string, default: "")
  attr(:close_path, :string, required: true)
  slot(:inner_block, required: true)

  def modal(assigns) do
    ~H"""
    <dialog
      id={@id}
      class={["modal", @show && "modal-open"]}
    >
      <div class="modal-box w-11/12 max-w-lg max-h-screen overflow-y-auto">
        <div class="flex items-center justify-between mb-4 pb-4 border-b border-base-300">
          <h2 class="font-display text-lg">{@title}</h2>
          <.link
            navigate={@close_path}
            class="btn btn-ghost btn-sm btn-square"
            aria-label="Close"
          >
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none"
              viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
              <path stroke-linecap="round" stroke-linejoin="round"
                d="M6 18L18 6M6 6l12 12" />
            </svg>
          </.link>
        </div>

        <div>
          {render_slot(@inner_block)}
        </div>
      </div>

      <form method="dialog" class="modal-backdrop">
        <.link navigate={@close_path}>close</.link>
      </form>
    </dialog>
    """
  end
end
