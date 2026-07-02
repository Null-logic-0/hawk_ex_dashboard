defmodule HawkExDashboard.UsageLive do
  use Phoenix.LiveView
  use HawkExDashboard.HTML
  import HawkExDashboard.{PageHeading, UsageCard, AccountPicker, EmptyState}

  alias HawkEx.{Entitlements, Config}
  alias HawkEx.Billing.Subscription

  import Ecto.Query

  @path "/hawk_ex/usage"

  @impl true
  def mount(_params, _session, socket) do
    accounts = load_accounts()

    {:ok,
     socket
     |> assign(:page_title, "Usage")
     |> assign(:current_path, @path)
     |> assign(:accounts, accounts)
     |> assign(:selected_id, nil)
     |> assign(:usage, nil)
     |> assign(:error, nil)}
  end

  @impl true
  def handle_event("select_account", %{"account_id" => ""}, socket) do
    {:noreply, assign(socket, selected_id: nil, usage: nil, error: nil)}
  end

  def handle_event("select_account", %{"account_id" => account_id}, socket) do
    case Entitlements.for_account(account_id) do
      {:ok, usage} ->
        {:noreply,
         socket
         |> assign(:selected_id, account_id)
         |> assign(:usage, usage)
         |> assign(:error, nil)}

      {:error, :no_subscription} ->
        {:noreply,
         socket
         |> assign(:selected_id, account_id)
         |> assign(:usage, nil)
         |> assign(:error, :no_subscription)}
    end
  end

  defp load_accounts do
    Config.repo().all(
      from(s in Subscription,
        where: s.status in ^Subscription.active_statuses(),
        select: s.account_id,
        distinct: true,
        order_by: [asc: s.account_id]
      )
    )
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app current_path={@current_path}>
      <.heading title={@page_title} />

      <.account_picker accounts={@accounts} selected_id={@selected_id} />

      <.empty_state
        :if={!@selected_id}
        title="No account selected"
        message="Select an account above to view its plan limits."
      />

      <.empty_state
        :if={@selected_id && @error == :no_subscription}
        title="No active subscription"
        message="This account has no active or trialing subscription."
      />

      <div :if={@usage} class="space-y-4 ">
        <div class="flex items-center gap-2 mb-6">
          <span class="text-sm text-base-content/60">Plan:</span>
          <span class="badge badge-primary">{@usage.plan.display_name}</span>
          <span :if={@usage.plan.trial_days > 0} class="badge badge-warning badge-sm">
            Trial available
          </span>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <.usage_card :for={feature <- @usage.features} feature={feature} />
        </div>
      </div>
    </Layouts.app>
    """
  end
end
