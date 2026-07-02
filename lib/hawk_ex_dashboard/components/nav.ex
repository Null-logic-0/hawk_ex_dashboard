defmodule HawkExDashboard.Nav do
  @moduledoc false
  use HawkExDashboard.HTML

  import HawkExDashboard.Logo

  attr(:current_path, :string, required: true)

  def sidebar(assigns) do
    ~H"""
    <ul class="menu p-4 w-64 min-h-full bg-base-100 shadow-lg">
      <.app_logo />

      <div class="divider"></div>
      <.nav_item path="/hawk_ex" label="Overview" current={@current_path} />
      <.nav_item path="/hawk_ex/billing" label="Billing" current={@current_path} />
      <.nav_item path="/hawk_ex/audit" label="Audit Logs" current={@current_path} />
      <.nav_item path="/hawk_ex/csv" label="CSV Exports" current={@current_path} />
      <.nav_item path="/hawk_ex/configuration" label="Configuration" current={@current_path} />
      <.nav_item path="/hawk_ex/entitlements" label="Entitlements" current={@current_path} />
      <.nav_item path="/hawk_ex/usage" label="Usage" current={@current_path} />
      <.nav_item path="/hawk_ex/events" label="Events" current={@current_path} />
    </ul>
    """
  end

  attr(:path, :string, required: true)
  attr(:label, :string, required: true)
  attr(:current, :string, required: true)

  defp nav_item(assigns) do
    active = assigns.current == assigns.path
    assigns = assign(assigns, :active, active)

    ~H"""
    <li class="text-sm">
      <.link
        navigate={@path}
        class={[
             "flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-colors",
             @active && "bg-primary text-primary-content",
             !@active && "text-base-content/70 hover:bg-base-200 hover:text-base-content"
           ]}
      >
        {@label}
      </.link>
    </li>
    """
  end
end
