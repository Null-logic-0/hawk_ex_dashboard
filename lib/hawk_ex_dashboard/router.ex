defmodule HawkExDashboard.Router do
  @moduledoc """
  Router integration for HAWK_EX Dashboard.

  ## Usage

  In your Phoenix router:

      defmodule MyAppWeb.Router do
        use Phoenix.Router
        import HawkExDashboard.Router

        scope "/" do
          # Protect with your existing auth pipeline
          pipe_through [:browser, :require_admin]

          hawk_ex_dashboard "/hawk_ex"
        end
      end

  This mounts the dashboard at `/hawk_ex` with the following routes:

      /hawk_ex              → Overview
      /hawk_ex/billing      → Billing
      /hawk_ex/audit        → Audit Logs
      /hawk_ex/csv          → CSV Exports
  """

  @doc """
  Mounts the HAWK_EX dashboard at the given path.

  ## Options

    * `:live_socket_path` — the path to the LiveView socket.
      Defaults to `"/live"`.

  ## Example

      hawk_ex_dashboard "/hawk_ex"

      # With options
      hawk_ex_dashboard "/hawk_ex", live_socket_path: "/custom_live"
  """
  defmacro hawk_ex_dashboard(path, opts \\ []) do
    quote bind_quoted: binding() do
      scope path, alias: false, as: :hawk_ex_dashboard do
        import Phoenix.LiveView.Router, only: [live: 4, live_session: 3]

        live_session :hawk_ex_dashboard,
          root_layout: {HawkExDashboard.Layouts, :root},
          on_mount: [] do
          live("/", HawkExDashboard.OverviewLive, :index, as: :hawk_ex_overview)
          live("/billing", HawkExDashboard.BillingLive, :index, as: :hawk_ex_billing)
          live("/audit", HawkExDashboard.AuditLive, :index, as: :hawk_ex_audit)
          live("/csv", HawkExDashboard.CsvLive, :index, as: :hawk_ex_csv)
        end
      end
    end
  end
end
