defmodule HawkExDashboard.ConfigRow do
  use HawkExDashboard.HTML

  attr(:label, :string, required: true)
  attr(:value, :string, required: true)

  def config_row(assigns) do
    ~H"""
    <div class="flex items-center justify-between px-5 py-2">
      <dt class="text-sm text-base-content/60">{@label}</dt>
      <dd class="font-mono-data text-sm">{@value}</dd>
    </div>
    """
  end
end
