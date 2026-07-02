defmodule HawkExDashboard.SubscriptionDetail do
  @moduledoc false
  use Phoenix.Component

  import HawkExDashboard.Formatters
  import HawkExDashboard.JSONViewer

  attr(:subscription, :map, required: true)

  def subscription_detail(assigns) do
    ~H"""
    <div class="space-y-4">
      <div class="flex items-center gap-3 py-2">
        <span class="badge badge-primary badge-sm">
          {@subscription.plan.display_name}
        </span>
        <span class={[
          "badge badge-sm",
          @subscription.status == "active" && "badge-success",
          @subscription.status == "trialing" && "badge-warning",
          @subscription.status == "past_due" && "badge-error",
          @subscription.status == "canceled" && "badge-ghost"
        ]}>
          {@subscription.status}
        </span>
      </div>

      <dl class="divide-y space-y-4 divide-base-300">
        <.detail_row label="Account ID" value={@subscription.account_id} mono />
        <.detail_row label="Subscription ID" value={@subscription.id} mono />
        <.detail_row label="Plan" value={@subscription.plan.display_name} />
        <.detail_row label="Status" value={@subscription.status} />
        <.detail_row
          label="Current period start"
          value={format_dt(@subscription.current_period_start)}
        />
        <.detail_row
          label="Current period end"
          value={format_dt(@subscription.current_period_end)}
        />
        <.detail_row
          :if={@subscription.trial_ends_at}
          label="Trial ends"
          value={format_dt(@subscription.trial_ends_at)}
        />
        <.detail_row
          :if={@subscription.canceled_at}
          label="Canceled at"
          value={format_dt(@subscription.canceled_at)}
        />
        <.detail_row
          :if={@subscription.external_id}
          label="External ID"
          value={@subscription.external_id}
          mono
        />
      </dl>

      <div :if={@subscription.metadata != %{}}>
        <h3 class="text-sm font-medium mb-2">Metadata</h3>
        <.json_viewer id={"sub-#{@subscription.id}-meta"} data={@subscription.metadata} />
      </div>
    </div>
    """
  end

  attr(:label, :string, required: true)
  attr(:value, :string, required: true)
  attr(:mono, :boolean, default: false)

  defp detail_row(assigns) do
    ~H"""
    <div class="flex justify-between py-3 gap-4">
      <dt class="text-sm text-base-content/60 shrink-0">{@label}</dt>
      <dd class={["text-sm text-right break-all", @mono && "font-mono-data text-xs"]}>
        {@value}
      </dd>
    </div>
    """
  end
end
