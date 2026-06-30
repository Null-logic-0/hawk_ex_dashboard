defmodule HawkExDashboard.BillingLive do
  use Phoenix.LiveView
  use HawkExDashboard.HTML

  alias HawkEx.Billing.{Plan, Subscription}
  alias HawkEx.Config
  import Ecto.Query

  @impl true
  def mount(_params, _session, socket) do
    plans = Config.repo().all(Plan)

    subscriptions =
      Config.repo().all(
        from(s in Subscription,
          where: s.status in ^Subscription.active_statuses(),
          preload: [:plan],
          order_by: [desc: s.inserted_at],
          limit: 50
        )
      )

    {:ok,
     socket
     |> assign(:page_title, "Billing")
     |> assign(:plans, plans)
     |> assign(:subscriptions, subscriptions)
     |> assign(:current_path, "/hawk_ex/billing")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app current_path={@current_path}>
      <h1 class="text-2xl font-bold mb-6">Billing</h1>

      <div class="mb-8">
        <h2 class="text-lg font-semibold mb-3">Plans</h2>
        <div class="flex gap-4 flex-wrap">
          <div :for={plan <- @plans}
            class="card bg-base-100 shadow w-48">
            <div class="card-body p-4">
              <h3 class="font-bold"><%= plan.display_name %></h3>
              <span class={[
                "badge badge-sm",
                plan.status == "active" && "badge-success",
                plan.status == "archived" && "badge-ghost"
              ]}>
                <%= plan.status %>
              </span>
              <p class="text-xs opacity-60 mt-1">
                Trial: <%= plan.trial_days %> days
              </p>
            </div>
          </div>
        </div>
      </div>

      <%!-- Active subscriptions --%>
      <div>
        <h2 class="text-lg font-semibold mb-3">
          Active Subscriptions
          <span class="badge badge-neutral ml-2">
            <%= length(@subscriptions) %>
          </span>
        </h2>
        <div class="card bg-base-100 shadow">
          <div class="overflow-x-auto">
            <table class="table table-zebra">
              <thead>
                <tr>
                  <th>Account</th>
                  <th>Plan</th>
                  <th>Status</th>
                  <th>Since</th>
                </tr>
              </thead>
              <tbody>
                <tr :for={sub <- @subscriptions}>
                  <td class="font-mono text-xs"><%= sub.account_id %></td>
                  <td>
                    <span class="badge badge-primary badge-sm">
                      <%= sub.plan.display_name %>
                    </span>
                  </td>
                  <td>
                    <span class={[
                      "badge badge-sm",
                      sub.status == "active" && "badge-success",
                      sub.status == "trialing" && "badge-warning"
                    ]}>
                      <%= sub.status %>
                    </span>
                  </td>
                  <td class="text-sm opacity-70">
                    <%= format_dt(sub.inserted_at) %>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  defp format_dt(nil), do: "—"
  defp format_dt(dt), do: Calendar.strftime(dt, "%b %d %H:%M")
end
