defmodule HawkExDashboard do
  @moduledoc """
  HAWK_EX Dashboard — LiveView developer tools for HAWK_EX.

  ## Installation

  Add to your `mix.exs`:

      {:hawk_ex_dashboard, "~> 0.1"}

  Mount in your router:

      defmodule MyAppWeb.Router do
        import HawkExDashboard.Router

        scope "/" do
          pipe_through [:browser, :require_admin]
          hawk_ex_dashboard "/hawk_ex"
        end
      end

  ## Sections

    * `/hawk_ex`          — Overview and recent activity
    * `/hawk_ex/billing`  — Plans and active subscriptions
    * `/hawk_ex/audit`    — Audit log timeline with filtering
    * `/hawk_ex/csv`      — CSV export job status

  ## Security

  The dashboard exposes internal data. Always protect it
  with an authentication pipeline in production.
  """
end
