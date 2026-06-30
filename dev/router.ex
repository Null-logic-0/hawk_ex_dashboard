defmodule HawkExDev.Router do
  use Phoenix.Router
  import Phoenix.LiveView.Router
  import HawkExDashboard.Router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, html: {HawkExDashboard.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)

  end

  get "/", HawkExDev.PageController, []

  hawk_ex_dashboard "/hawk_ex"
end
