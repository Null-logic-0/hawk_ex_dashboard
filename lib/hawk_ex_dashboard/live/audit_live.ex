defmodule HawkExDashboard.AuditLive do
  use Phoenix.LiveView
  use HawkExDashboard.HTML

  alias HawkEx.Audit

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Audit Logs")
      |> assign(:current_path, "/hawk_ex/audit")
      |> assign(:filter, "")
      |> load_page(1)

    {:ok, socket}
  end

  @impl true
  def handle_event("filter", %{"value" => value}, socket) do
    {:noreply, assign(socket, :filter, value)}
  end

  @impl true
  def handle_event("goto_page", %{"page" => page}, socket) do
    {:noreply, load_page(socket, String.to_integer(page))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app current_path={@current_path}>
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
    </Layouts.app>
    """
  end

  defp load_page(socket, page) do
    audit_page = Audit.recent(page: page, per_page: 20)

    socket
    |> assign(:logs, audit_page.entries)
    |> assign(:page, audit_page.page)
    |> assign(:total_pages, audit_page.total_pages)
    |> assign(:total_count, audit_page.total_count)
  end

  # ---Private-----------------------------------------------

  defp filtered_logs(logs, ""), do: logs

  defp filtered_logs(logs, filter) do
    Enum.filter(logs, fn log ->
      String.contains?(log.action, filter)
    end)
  end

  defp format_dt(nil), do: "—"
  defp format_dt(dt), do: Calendar.strftime(dt, "%b %d %H:%M")
end
