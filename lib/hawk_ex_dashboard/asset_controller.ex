defmodule HawkExDashboard.AssetController do
  @moduledoc false
  use Phoenix.Controller, formats: []

  def show(conn, %{"path" => path_segments}) do
    IO.inspect(path_segments, label: "ASSET PATH SEGMENTS")

    relative_path = Path.join(path_segments)
    IO.inspect(relative_path, label: "RELATIVE PATH")

    if String.contains?(relative_path, "..") do
      send_resp(conn, 403, "Forbidden")
    else
      priv_path = Application.app_dir(:hawk_ex_dashboard, "priv/static/assets")
      full_path = Path.join(priv_path, relative_path)

      if File.exists?(full_path) and File.regular?(full_path) do
        conn
        |> put_resp_content_type(MIME.from_path(full_path))
        |> send_file(200, full_path)
      else
        send_resp(conn, 404, "Not found")
      end
    end
  end
end
