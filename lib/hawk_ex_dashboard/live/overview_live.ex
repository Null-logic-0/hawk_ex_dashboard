defmodule HawkExDashboard.OverviewLive do
  use Phoenix.LiveView
  use HawkExDashboard.HTML

  @path "/hawk_ex"
  use HawkExDashboard.PaginatedSearch, path: @path
  import HawkExDashboard.{Table, PageHeading}

  alias HawkEx.Audit

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Overview")
     |> assign(:current_path, @path)
     |> assign(:sort_field, "inserted_at")
     |> assign(:sort_dir, "desc")
     |> assign(:total_pages, 1)
     |> assign(:total_count, 0)
     |> assign(:loading, true)
     |> assign(:error, nil)
     |> stream(:recent_events, [])}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    {:noreply, paginated_search_params(socket, params, &load_data/3)}
  end

  defp load_data(socket, page, search) do
    order_by = current_order_by(socket)

    start_async(socket, :load_recent, fn ->
      Audit.recent(
        page: page,
        per_page: 20,
        search: search,
        order_by: order_by
      )
    end)
  end

  @impl true
  def handle_async(:load_recent, {:ok, page_result}, socket) do
    handle_paginated_result(socket, @path, page_result, fn socket, result ->
      socket
      |> assign(:total_pages, result.total_pages)
      |> assign(:total_count, result.total_count)
      |> stream(:recent_events, result.entries, reset: true)
    end)
  end

  def handle_async(:load_recent, {:exit, reason}, socket) do
    {:noreply,
     socket
     |> assign(:loading, false)
     |> assign(:error, "Couldn't load recent activity (#{inspect(reason)})")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app current_path={@current_path}>
      <.heading title={@page_title} />

      <.table
        id="overview-recent-activity"
        stream={@streams.recent_events}
        page={@page}
        total_pages={@total_pages}
        total_count={@total_count}
        sort_field={@sort_field}
        sort_dir={@sort_dir}
        search={@search}
        search_placeholder="Search by action…"
        loading={@loading}
        error={@error}
        empty_title="No activity yet"
        empty_message="Once your app starts emitting events, they'll show up here."
      >
        <:col :let={log} label="Action" sortable={true} field="action" >
          <span class="badge badge-primary badge-sm cursor-pointer">{log.action}</span>
        </:col>
        <:col :let={log} label="Actor">
          <span class="font-mono-data text-xs">{log.actor_id || "system"}</span>
        </:col>
        <:col :let={log} label="Resource">
          <span class="font-mono-data text-xs">{log.resource_type || "—"}</span>
        </:col>
        <:col :let={log} label="When">
          <span class="text-sm opacity-70">{format_dt(log.inserted_at)}</span>
        </:col>
      </.table>
    </Layouts.app>
    """
  end
end
