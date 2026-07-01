defmodule HawkExDashboard.PageHeading do
  use HawkExDashboard.HTML

  def heading(assigns) do
    ~H"""
    <h1 class="text-3xl font-bold pb-6">{@title}</h1>
    """
  end
end
