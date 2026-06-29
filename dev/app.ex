defmodule HawkExDev.App do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      HawkExDev.Repo,
      {Phoenix.PubSub, name: HawkExDev.PubSub},
      HawkExDev.Endpoint,

    ]

    opts = [strategy: :one_for_one, name: HawkExDev.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
