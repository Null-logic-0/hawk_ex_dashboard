defmodule HawkExDashboard.BillingLive do
  use Phoenix.LiveView
  use HawkExDashboard.HTML
  @path "/hawk_ex/billing"
  use HawkExDashboard.PaginatedSearch, path: @path
  import HawkExDashboard.{Table, PageHeading, PlanCard, Modal, SubscriptionDetail}

  alias HawkEx.{Billing, Config}
  alias HawkEx.Billing.Plan

  @impl true
  def mount(_params, _session, socket) do
    plans = Config.repo().all(Plan)

    socket =
      socket
      |> assign(:page_title, "Billing")
      |> assign(:current_path, @path)
      |> assign(:plans, plans)
      |> assign(:total_pages, 1)
      |> assign(:total_count, 0)
      |> assign(:sort_field, "inserted_at")
      |> assign(:sort_dir, "desc")
      |> assign(:loading, true)
      |> assign(:error, nil)
      |> assign(:compact, false)
      |> assign(:close_path, @path)
      |> assign(:selected_subscription, nil)
      |> stream(:subscriptions, [])

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    selected =
      case params["modal"] do
        nil ->
          nil

        id ->
          Billing.get_subscription(id)
      end

    socket =
      socket
      |> assign(:selected_subscription, selected)
      |> then(
        &paginated_search_params(&1, params, fn s, page, search ->
          load_data(s, page, search)
        end)
      )
      |> then(&assign(&1, :close_path, build_path(&1, @path, [])))

    {:noreply, socket}
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
    handle_paginated_result(socket, @path, sub_page, fn socket, result ->
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

  defp modal_path(sub, search, page, sort_field, sort_dir) do
    base = "#{@path}?modal=#{sub.id}"
    qs = current_query_string(search, page, sort_field, sort_dir)
    if qs == "", do: base, else: "#{base}&#{qs}"
  end

  defp current_query_string(search, page, sort_field, sort_dir) do
    %{}
    |> then(fn m -> if search != "", do: Map.put(m, "search", search), else: m end)
    |> then(fn m -> if page != 1, do: Map.put(m, "page", page), else: m end)
    |> then(fn m ->
      if sort_field != "inserted_at", do: Map.put(m, "sort", sort_field), else: m
    end)
    |> then(fn m -> if sort_dir != "desc", do: Map.put(m, "dir", sort_dir), else: m end)
    |> URI.encode_query()
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

      <.modal
        id="subscription-modal"
        show={@selected_subscription != nil}
        title="Subscription Detail"
        close_path={@close_path}

      >
      <.subscription_detail
        :if={@selected_subscription}
        subscription={@selected_subscription}
      />

      </.modal>

      <.table
        id="billing-subscriptions"
        stream={@streams.subscriptions}
        page={@page}
        compact={@compact}
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
        <:col :let={sub} label="Account">
          <.link
            patch={modal_path(sub, @search, @page, @sort_field, @sort_dir)}
            class="font-mono-data text-xs hover:text-primary transition-colors"
          >
            {sub.account_id}
          </.link>
        </:col>
        <:col :let={sub} label="Plan">
          <span class="badge badge-primary badge-sm">{sub.plan.display_name}</span>
        </:col>
        <:col :let={sub} label="Status">
          <span class={[
            "badge badge-sm",
            sub.status == "active" && "badge-success",
            sub.status == "trialing" && "badge-warning",
            sub.status == "past_due" && "badge-error",
            sub.status == "canceled" && "badge-ghost"
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
