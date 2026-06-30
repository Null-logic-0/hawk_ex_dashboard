defmodule HawkExDev.Endpoint do
  use Phoenix.Endpoint, otp_app: :hawk_ex_dashboard

  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  @session_options [
    store: :cookie,
    key: "_hawk_ex_dev_key",
    signing_salt: "hawk_ex_dev",
    same_site: "Lax"
  ]

  socket("/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [session: @session_options]]
  )

  plug(Plug.Static,
    at: "/",
    from: :phoenix,
    gzip: false,
    only: ~w(favicon.ico)
  )

  plug(Plug.RequestId)
  plug(Plug.Telemetry, event_prefix: [:phoenix, :endpoint])


  plug(Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()
  )


  plug(Plug.MethodOverride)
  plug(Plug.Head)
  plug(Plug.Session, @session_options)
  plug(HawkExDev.Router)
end
