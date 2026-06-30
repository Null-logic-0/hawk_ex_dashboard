defmodule HawkExDashboard.AuditLive do
  use Phoenix.LiveView
  use HawkExDashboard.HTML
  use HawkExDashboard.PaginatedSearch, path: "/hawk_ex/audit"
  import HawkExDashboard.{Table, PageHeading}

  alias HawkEx.Audit

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Audit Logs")
     |> assign(:current_path, "/hawk_ex/audit")
     |> assign(:total_pages, 1)
     |> assign(:total_count, 0)
     |> assign(:loading, true)
     |> assign(:error, nil)
     |> stream(:logs, [])}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    {:noreply, paginated_search_params(socket, params, &load_data/3)}
  end

  defp load_data(socket, page, search) do
    start_async(socket, :load_logs, fn ->
      Audit.recent(page: page, per_page: 20, search: search)
    end)
  end

  @impl true
  def handle_async(:load_logs, {:ok, audit_page}, socket) do
    handle_paginated_result(socket, "/hawk_ex/audit", audit_page, fn socket, result ->
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
        page={@page}
        total_pages={@total_pages}
        total_count={@total_count}
        search={@search}
        search_placeholder="Search by action…"
        loading={@loading}
        error={@error}
        empty_title="No audit activity yet"
        empty_message="Once your app starts emitting events, they'll show up here."
      >
        <:col :let={log} label="Action">
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
