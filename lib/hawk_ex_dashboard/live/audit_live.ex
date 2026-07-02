defmodule HawkExDashboard.AuditLive do
  use Phoenix.LiveView
  use HawkExDashboard.HTML

  @path "/hawk_ex/audit"
  use HawkExDashboard.PaginatedSearch, path: @path
  import HawkExDashboard.{Table, PageHeading}

  alias HawkEx.Audit

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Audit Logs")
      |> assign(:current_path, @path)
      |> assign(:sort_field, "inserted_at")
      |> assign(:sort_dir, "desc")
      |> assign(:total_pages, 1)
      |> assign(:total_count, 0)
      |> assign(:loading, true)
      |> assign(:error, nil)
      |> assign(:compact, false)
      |> stream(:logs, [])

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    {:noreply, paginated_search_params(socket, params, &load_data/3)}
  end

  defp load_data(socket, page, search) do
    order_by = current_order_by(socket)

    start_async(socket, :load_logs, fn ->
      Audit.recent(
        page: page,
        per_page: 20,
        search: search,
        order_by: order_by
      )
    end)
  end

  @impl true
  def handle_async(:load_logs, {:ok, audit_page}, socket) do
    handle_paginated_result(socket, @path, audit_page, fn socket, result ->
      socket
      |> assign(:total_pages, result.total_pages)
      |> assign(:total_count, result.total_count)
      |> stream(:logs, result.entries, reset: true)
    end)
  end

  def handle_async(:load_logs, {:exit, reason}, socket) do
    {:noreply,
     socket
     |> assign(:loading, false)
     |> assign(:error, "Couldn't load audit logs (#{inspect(reason)})")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app current_path={@current_path}>
      <.heading title={@page_title} />

      <.table
        id="audit-logs"
        stream={@streams.logs}
        compact={@compact}
        page={@page}
        total_pages={@total_pages}
        total_count={@total_count}
        search={@search}
        sort_field={@sort_field}
        sort_dir={@sort_dir}
        search_placeholder="Search by action…"
        loading={@loading}
        error={@error}
        empty_title="No audit activity yet"
        empty_message="Once your app starts emitting events, they'll show up here."
      >
        <:col :let={log} label="Action" sortable={true} field="action">
          <span class="badge badge-primary badge-sm">{log.action}</span>
        </:col>
        <:col :let={log} label="Actor">
          <span class="font-mono-data text-xs">{log.actor_id || "system"}</span>
        </:col>
        <:col :let={log} label="Resource">
          <span class="font-mono-data text-xs">{log.resource_id || "—"}</span>
        </:col>
        <:col :let={log} label="Type">
          <span class="text-sm">{log.resource_type || "—"}</span>
        </:col>
        <:col :let={log} label="When">
          <span class="text-sm opacity-70">{format_dt(log.inserted_at)}</span>
        </:col>
      </.table>
    </Layouts.app>
    """
  end
end
