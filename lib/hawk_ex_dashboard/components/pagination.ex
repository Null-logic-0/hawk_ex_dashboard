defmodule HawkExDashboard.Pagination do
  @moduledoc false
  use HawkExDashboard.HTML

  attr(:page, :integer, required: true)
  attr(:total_pages, :integer, required: true)
  attr(:loading, :boolean, default: false)
  attr(:error, :string, default: nil)
  attr(:total_count, :integer, required: true)

  def pagination(assigns) do
    ~H"""
    <div :if={!@error && !@loading && @total_pages > 1}
      class="flex items-center justify-between p-4 border-t border-base-300">
      <div class="flex items-center gap-2">
        <p class="text-xs text-base-content/50">
          Total {@total_count} items
        </p>
        <span class="text-xs text-base-content/50">/</span>
        <p class="text-xs text-base-content/50">
          Page {@page} of {@total_pages}
        </p>
      </div>
      <div class="join">
        <button
          class="join-item btn btn-sm"
          disabled={@page <= 1}
          phx-click="table_page"
          phx-value-page={@page - 1}
        >
          ◂
        </button>
        <button :for={p <- page_window(@page, @total_pages)}
          class={["join-item btn btn-sm", p == @page && "btn-active"]}
          phx-click="table_page"
          phx-value-page={p}
        >
          {p}
        </button>
        <button
          class="join-item btn btn-sm"
          disabled={@page >= @total_pages}
          phx-click="table_page"
          phx-value-page={@page + 1}
        >
          ▸
        </button>
      </div>
    </div>
    """
  end

  defp page_window(nil, _), do: []
  defp page_window(_, nil), do: []

  defp page_window(current, total) do
    start = max(1, current - 2)
    stop = min(total, start + 4)
    start = max(1, stop - 4)
    start..stop
  end
end
