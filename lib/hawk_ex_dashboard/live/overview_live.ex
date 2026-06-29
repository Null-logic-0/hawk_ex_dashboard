defmodule HawkExDashboard.OverviewLive do
  use Phoenix.LiveView
  import HawkExDashboard.Nav

  alias HawkEx.Audit

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "HAWK_EX Overview")
     |> assign(:current_path, "/hawk_ex")
     |> assign(:recent_events, Audit.recent(limit: 10))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="drawer lg:drawer-open">
      <input id="drawer-toggle" type="checkbox" class="drawer-toggle" />

      <div class="drawer-content flex flex-col">
        <div class="navbar bg-base-100 shadow-sm lg:hidden">
          <label for="drawer-toggle" class="btn btn-ghost">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5"
              fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round"
                stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
            </svg>
          </label>
          <span class="text-lg font-bold">HAWK_EX</span>
        </div>

        <main class="p-6">
          <h1 class="text-2xl font-bold mb-6">Overview</h1>

          <div class="stats shadow w-full mb-6">
            <div class="stat">
              <div class="stat-title">Recent Audit Events</div>
              <div class="stat-value"><%= length(@recent_events) %></div>
              <div class="stat-desc">Last 10 entries</div>
            </div>
          </div>

          <div class="card bg-base-100 shadow">
            <div class="card-body">
              <h2 class="card-title">Recent Activity</h2>
              <div class="overflow-x-auto">
                <table class="table table-zebra">
                  <thead>
                    <tr>
                      <th>Action</th>
                      <th>Actor</th>
                      <th>Resource</th>
                      <th>When</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr :for={log <- @recent_events}>
                      <td>
                        <span class="badge badge-neutral">
                          <%= log.action %>
                        </span>
                      </td>
                      <td class="font-mono text-xs">
                        <%= log.actor_id || "system" %>
                      </td>
                      <td class="font-mono text-xs">
                        <%= log.resource_type || "—" %>
                      </td>
                      <td class="text-sm opacity-70">
                        <%= format_dt(log.inserted_at) %>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </main>
      </div>

      <div class="drawer-side">
        <label for="drawer-toggle" class="drawer-overlay"></label>
        <.sidebar current_path={@current_path} />
      </div>
    </div>
    """
  end

  defp format_dt(nil), do: "—"
  defp format_dt(dt), do: Calendar.strftime(dt, "%b %d %H:%M")
end
