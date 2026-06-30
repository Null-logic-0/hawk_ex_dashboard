defmodule HawkExDashboard.Logo do
  @moduledoc false
  use HawkExDashboard.HTML

  def app_logo(assigns) do
    ~H"""
    <div class="px-5 pb-6 border-b border-base-300">
      <a href="/" class="flex items-center gap-2.5">
        <img src="/hawk_ex/assets/images/logo.png" alt="HAWK_EX" class="w-12 h-12 shrink-0 rounded-lg object-contain" />
        <div>
          <p class="font-bold text-base leading-tight">Hawk_ex</p>
          <p class="text-xs text-base-content/50 leading-tight">Dashboard</p>
        </div>
      </a>
    </div>

    """
  end
end
