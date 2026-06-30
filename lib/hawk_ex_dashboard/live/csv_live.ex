defmodule HawkExDashboard.CsvLive do
  use Phoenix.LiveView
  use HawkExDashboard.HTML

  alias HawkEx.Config
  alias HawkEx.CSV.Export
  import Ecto.Query

  @impl true
  def mount(_params, _session, socket) do
    exports =
      Config.repo().all(
        from(e in Export,
          order_by: [desc: e.inserted_at],
          limit: 50
        )
      )

    {:ok,
     socket
     |> assign(:page_title, "CSV Exports")
     |> assign(:current_path, "/hawk_ex/csv")
     |> assign(:exports, exports)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app current_path={@current_path}>
      <h1 class="text-2xl font-bold mb-6">CSV Exports</h1>

      <div class="card bg-base-100 shadow">
        <div class="overflow-x-auto">
          <table class="table table-zebra">
            <thead>
              <tr>
                <th>Type</th>
                <th>Status</th>
                <th>Rows</th>
                <th>Error</th>
                <th>Created</th>
              </tr>
            </thead>
            <tbody>
              <tr :for={export <- @exports}>
                <td>
                  <span class="badge badge-ghost badge-sm">
                    <%= export.export_type %>
                  </span>
                </td>
                <td>
                  <span class={[
                    "badge badge-sm",
                    export.status == "completed" && "badge-success",
                    export.status == "pending" && "badge-warning",
                    export.status == "failed" && "badge-error"
                  ]}>
                    <%= export.status %>
                  </span>
                </td>
                <td><%= export.row_count || "—" %></td>
                <td class="text-xs text-error max-w-xs truncate">
                  <%= export.error_message || "—" %>
                </td>
                <td class="text-sm opacity-70">
                  <%= format_dt(export.inserted_at) %>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
