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

  attr(:page, :integer, default: nil)
  attr(:total_pages, :integer, default: nil)
  attr(:total_count, :integer, default: nil)

  attr(:search, :string, default: "")
  attr(:search_placeholder, :string, default: "Search…")
  attr(:show_search, :boolean, default: true)

  attr(:loading, :boolean, default: false)
  attr(:error, :string, default: nil)

  attr(:empty_title, :string, default: "No data")
  attr(:empty_message, :string, default: "Nothing to show yet.")

  attr(:sort_field, :string, default: nil)
  attr(:sort_dir, :string, default: "desc")

  slot :col, required: true do
    attr(:label, :string, required: true)
    attr(:sortable, :boolean)
    attr(:field, :string)
  end

  def table(assigns) do
    ~H"""
    <div class="card border border-base-300 bg-base-100 shadow-sm">
      <div class="card-body p-0">

        <%!-- Toolbar --%>
        <div class="flex items-center gap-4 p-4 border-b border-base-300">
          <.search
            search={@search}
            search_placeholder={@search_placeholder}
            show_search={@show_search}
          />
          <p :if={@total_count != nil} class="text-xs text-base-content/50">
            {@total_count} total
          </p>
        </div>

        <%!-- Table --%>
        <div class="overflow-x-auto">
          <table :if={!@error} class={["table", !@loading && "table-zebra"]}>
            <thead>
              <tr>
                <th :for={col <- @col} >
                  <button
                    :if={col[:sortable]}
                    class="flex items-center gap-1  hover:text-base-content transition-colors"
                    phx-click="table_sort"
                    phx-value-field={col[:field]}
                  >
                    {col.label}
                    <span class="text-xs">
                      <span :if={@sort_field == col[:field] && @sort_dir == "asc"} class="text-primary">↑</span>
                      <span :if={@sort_field == col[:field] && @sort_dir == "desc"} class="text-primary">↓</span>
                      <span :if={@sort_field != col[:field]} class="opacity-30">↕</span>
                    </span>
                  </button>
                  <span :if={!col[:sortable]}>{col.label}</span>
                </th>
              </tr>
            </thead>

            <%!-- Loading skeleton --%>
            <tbody :if={@loading}>
              <tr :for={_ <- 1..6}>
                <td :for={_ <- @col}>
                  <div class="h-12 bg-base-200 animate-pulse rounded"></div>
                </td>
              </tr>
            </tbody>

            <%!-- Empty state --%>
            <tbody :if={!@loading && @total_count == 0}>
              <tr>
                <td colspan={length(@col)} class="text-center py-12">
                  <.empty_state title={@empty_title} message={@empty_message} />
                </td>
              </tr>
            </tbody>

            <%!-- Stream rows --%>
            <tbody
              :if={!@loading && @total_count > 0 && @stream}
              id={"#{@id}-tbody"}
              phx-update="stream"
            >
              <tr :for={{dom_id, row} <- @stream} id={dom_id}>
                <td :for={col <- @col}>{render_slot(col, row)}</td>
              </tr>
            </tbody>

            <%!-- Plain list rows --%>
            <tbody :if={!@loading && @total_count > 0 && !@stream}>
              <tr :for={row <- @rows} id={row_id(@row_id, row)}>
                <td :for={col <- @col}>{render_slot(col, row)}</td>
              </tr>
            </tbody>
          </table>

          <%!-- Error state --%>
          <div :if={@error} class="p-8 text-center">
            <.error_state message={@error} />
          </div>
        </div>

        <%!-- Pagination footer --%>
        <.pagination
          :if={is_integer(@page) && is_integer(@total_pages) && @total_pages > 1}
          page={@page}
          total_pages={@total_pages}
          total_count={@total_count}
          loading={@loading}
          error={@error}
        />
      </div>
    </div>
    """
  end

  defp row_id(nil, _row), do: nil
  defp row_id(fun, row) when is_function(fun, 1), do: fun.(row)
end
