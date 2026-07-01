defmodule HawkExDashboard.Logo do
  @moduledoc false
  use HawkExDashboard.HTML

  def app_logo(assigns) do
    ~H"""
      <a href="/" class="flex items-center gap-2.5">
        <img
          src="/hawk_ex/assets/images/logo.png"
          alt="hawk_ex"
          class="w-14 h-14 shrink-0" />
        <div>
          <p class="font-bold text-primary text-xl leading-tight">Hawk_Ex</p>
          <p class="text-xs text-base-content/50 leading-tight">Dashboard</p>
        </div>
      </a>

    """
  end
end
