defmodule HawkExDashboard.Table do
  @moduledoc """
  Shared table shell per design spec §5 — search, sort, pagination,
  loading/empty/error states. All state (search query, current page,
  sort column) is owned by the parent LiveView and passed in as
  assigns; this component only renders and emits events.

  Supports two row-data modes:
    * `rows` — a plain list, fully re-rendered each update
    * `stream` — a Phoenix.LiveView.LiveStream, for high-volume or
      continuously-updating lists (see spec §6)
  Exactly one of `rows`/`stream` should be passed.
  """
  use HawkExDashboard.HTML
  import HawkExDashboard.{EmptyState, ErrorState, Search, Pagination}

  attr(:id, :string, required: true)
  attr(:rows, :list, default: [])
  attr(:stream, :any, default: nil)
  attr(:row_id, :any, default: nil)

  attr(:page, :integer, required: true)
  attr(:total_pages, :integer, required: true)
  attr(:total_count, :integer, required: true)

  attr(:search, :string, default: "")
  attr(:search_placeholder, :string, default: "Search…")
  attr(:show_search, :boolean, default: true)

  attr(:loading, :boolean, default: false)
  attr(:error, :string, default: nil)

  attr(:empty_title, :string, default: "No data")
  attr(:empty_message, :string, default: "Nothing to show yet.")

  slot :col, required: true do
    attr(:label, :string, required: true)
  end

  def table(assigns) do
    ~H"""
    <div class="card border border-base-300 bg-base-100 shadow-sm">
      <div class="card-body p-0">

        <div class="flex items-center gap-4 p-4 border-b border-base-300">
          <.search
            search={@search}
            search_placeholder={@search_placeholder}
            show_search={@show_search}
          />
          <p class="text-xs text-base-content/50">
            {@total_count} total
          </p>
        </div>

        <div class="overflow-x-auto">
          <table :if={!@error} class={["table", !@loading && "table-zebra"]}>
            <thead>
              <tr>
                <th :for={col <- @col}>{col.label}</th>
              </tr>
            </thead>

            <tbody :if={@loading}>
              <tr :for={_ <- 1..6}>
                <td :for={_ <- @col}>
                  <div class="h-12 bg-base-200 animate-pulse"></div>
                </td>
              </tr>
            </tbody>

            <tbody :if={!@loading && @total_count == 0}>
              <tr>
                <td colspan={length(@col)} class="text-center py-12">
                  <.empty_state title={@empty_title} message={@empty_message} />
                </td>
              </tr>
            </tbody>

            <tbody
              :if={!@loading && @total_count > 0 && @stream}
              id={"#{@id}-tbody"}
              phx-update="stream"
            >
              <tr :for={{dom_id, row} <- @stream} id={dom_id}>
                <td :for={col <- @col}>{render_slot(col, row)}</td>
              </tr>
            </tbody>

            <tbody :if={!@loading && @total_count > 0 && !@stream}>
              <tr :for={row <- @rows} id={row_id(@row_id, row)}>
                <td :for={col <- @col}>{render_slot(col, row)}</td>
              </tr>
            </tbody>
          </table>

          <div :if={@error} class="p-8 text-center">
            <.error_state message={@error} />
          </div>
        </div>

        <.pagination page={@page}
          total_pages={@total_pages}
          loading={@loading}
          error={@error}
          total_count={@total_count}
        />

      </div>
    </div>
    """
  end

  defp row_id(nil, _row), do: nil
  defp row_id(fun, row) when is_function(fun, 1), do: fun.(row)
end
