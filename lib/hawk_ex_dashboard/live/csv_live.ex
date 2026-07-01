defmodule HawkExDashboard.CsvLive do
  use Phoenix.LiveView
  use HawkExDashboard.HTML
  use HawkExDashboard.PaginatedSearch, path: "/hawk_ex/csv"
  import HawkExDashboard.{Table, PageHeading}

  alias HawkEx.CSV

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "CSV Exports")
     |> assign(:current_path, "/hawk_ex/csv")
     |> assign(:total_pages, 1)
     |> assign(:total_count, 0)
     |> assign(:sort_field, "inserted_at")
     |> assign(:sort_dir, "desc")
     |> assign(:loading, true)
     |> assign(:error, nil)
     |> stream(:exports, [])}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    {:noreply, paginated_search_params(socket, params, &load_data/3)}
  end

  defp load_data(socket, page, search) do
    order_by = current_order_by(socket)

    start_async(socket, :load_exports, fn ->
      CSV.recent_exports(
        page: page,
        per_page: 20,
        search: search,
        order_by: order_by
      )
    end)
  end

  @impl true
  def handle_async(:load_exports, {:ok, export_page}, socket) do
    handle_paginated_result(socket, "/hawk_ex/csv", export_page, fn socket, result ->
      socket
      |> assign(:total_pages, result.total_pages)
      |> assign(:total_count, result.total_count)
      |> stream(:exports, result.entries, reset: true)
    end)
  end

  def handle_async(:load_exports, {:exit, reason}, socket) do
    {:noreply,
     socket
     |> assign(:loading, false)
     |> assign(:error, "Couldn't load CSV exports (#{inspect(reason)})")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app current_path={@current_path}>
      <.heading title={@page_title} />

      <.table
        id="csv-exports"
        stream={@streams.exports}
        page={@page}
        total_pages={@total_pages}
        total_count={@total_count}
        sort_field={@sort_field}
        sort_dir={@sort_dir}
        search={@search}
        search_placeholder="Search by export type…"
        loading={@loading}
        error={@error}
        empty_title="No exports yet"
        empty_message="CSV jobs created from your app will appear here."
      >
        <:col :let={export} label="Type">
          <span class="badge badge-ghost badge-sm">{export.export_type}</span>
        </:col>
        <:col :let={export} label="Status">
          <span class={[
            "badge badge-sm",
            export.status == "completed" && "badge-success",
            export.status == "pending" && "badge-warning",
            export.status == "failed" && "badge-error"
          ]}>
            {export.status}
          </span>
        </:col>
        <:col :let={export} label="Rows">
          {export.row_count || "—"}
        </:col>
        <:col :let={export} label="Error">
          <span class="text-xs text-error max-w-xs truncate block">
            {export.error_message || "—"}
          </span>
        </:col>
        <:col :let={export} label="Created" sortable={true} field="inserted_at">
          <span class="text-sm opacity-70">{format_dt(export.inserted_at)}</span>
        </:col>
        <:col :let={export} label="Download">
          <a :if={export.status == "completed"}
            href={"/hawk_ex/csv/#{export.id}/download"}
            class="btn btn-ghost btn-xs"
            aria-label={"Download #{export.export_type}.csv"}>
            <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none"
              viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
              <path stroke-linecap="round" stroke-linejoin="round"
                d="M3 16.5v2.25A2.25 2.25 0 005.25 21h13.5A2.25 2.25 0 0021 18.75V16.5M16.5 12L12 16.5m0 0L7.5 12m4.5 4.5V3" />
            </svg>
          </a>
        </:col>
      </.table>
    </Layouts.app>
    """
  end
end
