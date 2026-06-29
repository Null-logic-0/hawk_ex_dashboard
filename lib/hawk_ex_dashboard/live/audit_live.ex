defmodule HawkExDashboard.AuditLive do
  use Phoenix.LiveView

  alias HawkEx.Audit

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Audit Logs")
     |> assign(:logs, Audit.recent(limit: 50))
     |> assign(:filter, "")}
  end

  @impl true
  def handle_event("filter", %{"value" => value}, socket) do
    {:noreply, assign(socket, :filter, value)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-6">
      <h1 class="text-2xl font-bold mb-6">Audit Logs</h1>

      <div class="card bg-base-100 shadow">
        <div class="card-body">
          <%!-- Filter input --%>
          <div class="mb-4">
            <input
              type="text"
              placeholder="Filter by action..."
              class="input input-bordered w-full max-w-sm"
              phx-keyup="filter"
              value={@filter}
            />
          </div>

          <div class="overflow-x-auto">
            <table class="table table-zebra">
              <thead>
                <tr>
                  <th>Action</th>
                  <th>Actor</th>
                  <th>Resource</th>
                  <th>Type</th>
                  <th>When</th>
                </tr>
              </thead>
              <tbody>
                <tr :for={log <- filtered_logs(@logs, @filter)}>
                  <td>
                    <span class="badge badge-neutral badge-sm">
                      <%= log.action %>
                    </span>
                  </td>
                  <td class="font-mono text-xs">
                    <%= log.actor_id || "system" %>
                  </td>
                  <td class="font-mono text-xs">
                    <%= log.resource_id || "—" %>
                  </td>
                  <td class="text-sm"><%= log.resource_type || "—" %></td>
                  <td class="text-sm opacity-70">
                    <%= format_dt(log.inserted_at) %>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp filtered_logs(logs, ""), do: logs

  defp filtered_logs(logs, filter) do
    Enum.filter(logs, fn log ->
      String.contains?(log.action, filter)
    end)
  end

  defp format_dt(nil), do: "—"
  defp format_dt(dt), do: Calendar.strftime(dt, "%b %d %H:%M")
end
