defmodule HawkExDashboard.Logo do
  @moduledoc false
  use HawkExDashboard.HTML

  def app_logo(assigns) do
    ~H"""

      <a href="/" class="flex items-center gap-2.5">
        <img
          src="/hawk_ex/assets/images/logo.png"
          alt="hawk_ex"
          class="w-14 h-12 shrink-0 rounded-lg object-contain" />
        <div>
          <p class="font-bold text-primary  text-3xl leading-tight">Hawk_Ex</p>
          <p class="text-xs text-base-content/50 leading-tight">Dashboard</p>
        </div>
      </a>

    """
  end
end
