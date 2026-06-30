defmodule HawkExDashboard.Nav do
  @moduledoc false
  use HawkExDashboard.HTML

  import HawkExDashboard.Logo

  attr(:current_path, :string, required: true)

  def sidebar(assigns) do
    ~H"""
    <ul class="menu p-4 w-64 min-h-full text-sm bg-base-100 shadow-lg">
      <.app_logo />
      <.nav_item path="/hawk_ex" label="Overview" current={@current_path} />
      <.nav_item path="/hawk_ex/billing" label="Billing" current={@current_path} />
      <.nav_item path="/hawk_ex/audit" label="Audit Logs" current={@current_path} />
      <.nav_item path="/hawk_ex/csv" label="CSV Exports" current={@current_path} />
    </ul>
    """
  end

  attr(:path, :string, required: true)
  attr(:label, :string, required: true)
  attr(:current, :string, required: true)

  defp nav_item(assigns) do
    ~H"""
    <li>
      <.link
        navigate={@path}
        class={if @current == @path, do: "bg-base-200 text-primary font-semibold", else: "font-medium"}
      >
        <%= @label %>
      </.link>
    </li>
    """
  end
end
