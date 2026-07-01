defmodule HawkExDashboard.BillingLive do
  use Phoenix.LiveView
  use HawkExDashboard.HTML
  use HawkExDashboard.PaginatedSearch, path: "/hawk_ex/billing"
  import HawkExDashboard.{Table, PageHeading, PlanCard}

  alias HawkEx.Billing
  alias HawkEx.Config
  alias HawkEx.Billing.Plan

  @impl true
  def mount(_params, _session, socket) do
    plans = Config.repo().all(Plan)

    {:ok,
     socket
     |> assign(:page_title, "Billing")
     |> assign(:current_path, "/hawk_ex/billing")
     |> assign(:plans, plans)
     |> assign(:total_pages, 1)
     |> assign(:total_count, 0)
     |> assign(:sort_field, "inserted_at")
     |> assign(:sort_dir, "desc")
     |> assign(:loading, true)
     |> assign(:error, nil)
     |> stream(:subscriptions, [])}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    {:noreply, paginated_search_params(socket, params, &load_data/3)}
  end

  defp load_data(socket, page, search) do
    order_by = current_order_by(socket)

    start_async(socket, :load_subscriptions, fn ->
      Billing.recent_subscriptions(
        page: page,
        per_page: 20,
        search: search,
        order_by: order_by
      )
    end)
  end

  @impl true
  def handle_async(:load_subscriptions, {:ok, sub_page}, socket) do
    handle_paginated_result(socket, "/hawk_ex/billing", sub_page, fn socket, result ->
      socket
      |> assign(:total_pages, result.total_pages)
      |> assign(:total_count, result.total_count)
      |> stream(:subscriptions, result.entries, reset: true)
    end)
  end

  def handle_async(:load_subscriptions, {:exit, reason}, socket) do
    {:noreply,
     socket
     |> assign(:loading, false)
     |> assign(:error, "Couldn't load subscriptions (#{inspect(reason)})")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app current_path={@current_path}>
      <.heading title={@page_title} />

      <div class="mb-8">
        <h2 class="text-lg font-semibold mb-3">Plans</h2>
        <div class="flex gap-4 flex-wrap">
          <.plan_card :for={plan <- @plans} plan={plan} />
        </div>
      </div>

        <h2 class="text-lg font-semibold mb-3">Active Subscriptions</h2>

        <.table
          id="billing-subscriptions"
          stream={@streams.subscriptions}
          page={@page}
          total_pages={@total_pages}
          total_count={@total_count}
          sort_field={@sort_field}
          sort_dir={@sort_dir}
          search={@search}
          search_placeholder="Search by account ID…"
          loading={@loading}
          error={@error}
          empty_title="No subscriptions yet"
          empty_message="Subscriptions will appear here once accounts subscribe."
        >
          <:col :let={sub} label="Action" >
            <span class="font-mono-data text-xs">{sub.account_id}</span>
          </:col>
          <:col :let={sub} label="Plan">
            <span class="badge badge-primary badge-sm">{sub.plan.display_name}</span>
          </:col>
          <:col :let={sub} label="Status">
            <span class={[
              "badge badge-sm",
              sub.status == "active" && "badge-success",
              sub.status == "trialing" && "badge-warning"
            ]}>
              {sub.status}
            </span>
          </:col>
          <:col :let={sub} label="Since" sortable={true} field="inserted_at">
            <span class="text-sm opacity-70">{format_dt(sub.inserted_at)}</span>
          </:col>
        </.table>

    </Layouts.app>
    """
  end
end
