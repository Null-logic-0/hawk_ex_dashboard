defmodule HawkExDev.PageController do
  use Phoenix.Controller, formats: []

  def init(opts), do: opts

  def call(conn, _opts) do
    conn
    |> redirect(to: "/hawk_ex")
    |> halt()
  end
end
