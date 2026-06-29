defmodule HawkExDashboard.Nav do
  @moduledoc false
  use Phoenix.Component

  attr(:current_path, :string, required: true)

  def sidebar(assigns) do
    ~H"""
    <ul class="menu p-4 w-64 min-h-full bg-base-100 shadow-lg">
      <li class="menu-title">
        <span class="text-lg font-bold text-primary">🦅 HAWK_EX</span>
      </li>
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
        class={if @current == @path, do: "active", else: ""}
      >
        <%= @label %>
      </.link>
    </li>
    """
  end
end
