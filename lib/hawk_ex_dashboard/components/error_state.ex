defmodule HawkExDashboard.ErrorState do
  use HawkExDashboard.HTML

  attr(:message, :string, required: true)

  def error_state(assigns) do
    ~H"""
    <div class="flex flex-col items-center gap-2 text-error">
      <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8" fill="none"
        viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
        <path stroke-linecap="round" stroke-linejoin="round"
          d="M12 9v3.75m9-.75a9 9 0 11-18 0 9 9 0 0118 0zm-8.25 3.75h.008v.008h-.008v-.008z" />
      </svg>
      <p class="text-sm font-medium">Couldn't load data</p>
      <p class="text-xs opacity-80">{@message}</p>
      <button class="btn btn-sm btn-outline btn-error mt-1" phx-click="table_retry">
        Retry
      </button>
    </div>
    """
  end
end
