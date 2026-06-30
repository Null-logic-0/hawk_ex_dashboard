defmodule HawkExDashboard.ExportDownloadController do
  @moduledoc false
  use Phoenix.Controller, formats: []

  alias HawkEx.CSV

  def show(conn, %{"id" => id}) do
    with {:ok, export} <- CSV.get_export(id),
         {:ok, content} <- CSV.read_export(export) do
      filename = "#{export.export_type}_#{export.id}.csv"

      conn
      |> put_resp_content_type("text/csv")
      |> put_resp_header("content-disposition", ~s(attachment; filename="#{filename}"))
      |> send_resp(200, content)
    else
      {:error, :not_found} ->
        send_resp(conn, 404, "Export not found")

      {:error, {:export_not_ready, status}} ->
        send_resp(conn, 409, "Export is #{status}, not ready for download")

      {:error, reason} ->
        send_resp(conn, 500, "Couldn't read export: #{inspect(reason)}")
    end
  end
end
