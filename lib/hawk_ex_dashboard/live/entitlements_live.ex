defmodule HawkExDashboard.EntitlementsLive do
  use Phoenix.LiveView
  use HawkExDashboard.HTML
  import HawkExDashboard.PageHeading

  alias HawkEx.Entitlements

  @impl true
  def mount(_params, _session, socket) do
    data = Entitlements.matrix()

    {:ok,
     socket
     |> assign(:page_title, "Entitlements")
     |> assign(:current_path, "/hawk_ex/entitlements")
     |> assign(:plans, data.plans)
     |> assign(:features, data.features)
     |> assign(:matrix, data.matrix)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app current_path={@current_path}>
      <.heading title={@page_title} />

      <div :if={@plans == []} class="card bg-base-100 border border-base-300 shadow-sm p-8 text-center">
        <p class="text-sm text-base-content/50">No plans configured yet.</p>
        <p class="text-xs text-base-content/40 mt-1">
          <a href="https://hexdocs.pm/hawk_ex" class="link link-hover underline" target="_blank">
            See documentation
          </a>
          to set up plans and features.
        </p>
      </div>

      <div :if={@plans !== []} class="card bg-base-100 border border-base-300 shadow-sm overflow-hidden">
        <div class="overflow-x-auto">
          <table class="table">
            <thead>
              <tr>
                <th class="bg-base-200 w-48 sticky left-0 z-5">Feature</th>
                <th :for={plan <- @plans} class="text-center">
                  <div class="font-display text-base">{plan.display_name}</div>
                  <div :if={plan.trial_days > 0} class="text-xs font-normal opacity-60">
                    {plan.trial_days} day trial
                  </div>
                </th>
              </tr>
            </thead>
            <tbody>
              <tr :for={feature <- @features}>
                <td class="bg-base-100 sticky left-0 z-5 border-r border-base-300">
                  <div class="font-medium text-sm">{format_key(feature.key)}</div>
                  <div :if={feature.description} class="text-xs text-base-content/50">
                    {feature.description}
                  </div>
                </td>
                <td :for={plan <- @plans} class="text-center">
                  <.entitlement_cell
                    value={Map.get(@matrix, {plan.id, feature.key})}
                    type={feature.feature_type}
                  />
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </Layouts.app>
    """
  end

  attr(:value, :string, default: nil)
  attr(:type, :string, required: true)

  defp entitlement_cell(%{type: "boolean"} = assigns) do
    ~H"""
    <span :if={@value == "true"} class="text-success" aria-label="Included">
      <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 inline" fill="none"
        viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
        <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7" />
      </svg>
      <span class="sr-only">Included</span>
    </span>
    <span :if={@value != "true"} class="text-base-content/30" aria-label="Not included">
      <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 inline" fill="none"
        viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
        <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
      </svg>
      <span class="sr-only">Not included</span>
    </span>
    """
  end

  defp entitlement_cell(%{type: "limit"} = assigns) do
    ~H"""
    <span :if={@value == "unlimited"} class="font-mono-data text-sm text-success">
      Unlimited
    </span>
    <span :if={@value == "0"} class="text-base-content/30 text-sm">
      —
    </span>
    <span :if={@value not in [nil, "unlimited", "0"]} class="font-mono-data text-sm">
      {format_number(@value)}
    </span>
    """
  end

  defp entitlement_cell(assigns) do
    ~H"""
    <span class="text-base-content/30 text-sm">—</span>
    """
  end

  defp format_key(key) do
    key
    |> String.replace("_", " ")
    |> String.split()
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end
end
