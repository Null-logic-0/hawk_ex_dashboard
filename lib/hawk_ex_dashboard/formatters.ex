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
end
