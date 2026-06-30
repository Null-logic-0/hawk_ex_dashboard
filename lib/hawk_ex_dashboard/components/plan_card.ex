defmodule HawkExDashboard.PlanCard do
  use HawkExDashboard.HTML

  attr(:plan, :map, required: true)

  def plan_card(assigns) do
    ~H"""
    <div class="card bg-base-100 border border-base-300 shadow-sm w-48">
      <div class="card-body p-4">
        <h3 class="font-display text-base">{@plan.display_name}</h3>
        <span class={[
          "badge badge-sm",
          @plan.status == "active" && "badge-success",
          @plan.status == "archived" && "badge-ghost"
        ]}>
          {@plan.status}
        </span>
        <p class="text-xs opacity-60 mt-1">Trial: {@plan.trial_days} days</p>
      </div>
    </div>
    """
  end
end
