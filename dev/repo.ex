defmodule HawkExDev.Repo do
  use Ecto.Repo,
    otp_app: :hawk_ex_dashboard,
    adapter: Ecto.Adapters.Postgres
end
