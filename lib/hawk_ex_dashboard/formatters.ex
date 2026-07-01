defmodule HawkExDashboard.Formatters do
  @moduledoc """
  Shared formatting helpers for displaying data across dashboard pages.
  """

  @doc """
  Formats a DateTime as a short, human-readable string for table cells.
  Returns an em dash for nil.
  """
  def format_dt(nil), do: "—"
  def format_dt(%DateTime{} = dt), do: Calendar.strftime(dt, "%b %d %H:%M")

  @doc "Formats an integer string with thousands separators."
  def format_number(value) when is_binary(value) do
    case Integer.parse(value) do
      {n, ""} ->
        n
        |> Integer.to_string()
        |> String.graphemes()
        |> Enum.reverse()
        |> Enum.chunk_every(3)
        |> Enum.join(",")
        |> String.graphemes()
        |> Enum.reverse()
        |> Enum.join()

      _ ->
        value
    end
  end
end
