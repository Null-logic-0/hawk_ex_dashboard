defmodule HawkExDashboard.EmptyState do
  use HawkExDashboard.HTML

  attr(:title, :string, required: true)
  attr(:message, :string, required: true)

  def empty_state(assigns) do
    ~H"""
    <div class="flex flex-col items-center gap-2 text-base-content/50">
      <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8" fill="none"
        viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
        <path stroke-linecap="round" stroke-linejoin="round"
          d="M9.75 9.75l4.5 4.5m0-4.5l-4.5 4.5M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
      </svg>
      <p class="text-sm font-medium text-base-content/70">{@title}</p>
      <p class="text-xs">{@message}</p>
    </div>
    """
  end
end
