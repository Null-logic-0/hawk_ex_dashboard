defmodule HawkExDashboard.UsageCard do
  use HawkExDashboard.HTML

  attr(:feature, :map, required: true)

  def usage_card(%{feature: %{feature_type: "boolean"}} = assigns) do
    ~H"""
    <div class="card bg-base-100 border border-base-300 shadow-sm">
      <div class="card-body p-4">
        <div class="flex items-center justify-between">
          <h3 class="font-medium text-sm">{format_key(@feature.key)}</h3>
          <span class={[
            "badge badge-sm",
            @feature.value == "true" && "badge-success",
            @feature.value != "true" && "badge-ghost"
          ]}>
            {if @feature.value == "true", do: "Included", else: "Not included"}
          </span>
        </div>
        <p :if={@feature.description} class="text-xs text-base-content/50 mt-1">
          {@feature.description}
        </p>
      </div>
    </div>
    """
  end

  def usage_card(%{feature: %{feature_type: "limit"}} = assigns) do
    ~H"""
    <div class="card bg-base-100 border border-base-300 shadow-sm">
      <div class="card-body p-4">
        <div class="flex items-center justify-between mb-2">
          <h3 class="font-medium text-sm">{format_key(@feature.key)}</h3>
          <span class="font-mono-data text-sm">
            {format_number(@feature.value)}
          </span>
        </div>
        <div class="w-full bg-base-300 rounded-full h-1.5">
          <div
            class={[
              "h-1.5 rounded-full",
              @feature.value == "unlimited" && "bg-success w-full",
              @feature.value != "unlimited" && "bg-primary w-1/2"
            ]}
          ></div>
        </div>
        <p class="text-xs text-base-content/40 mt-1">Plan limit</p>
        <p :if={@feature.description} class="text-xs text-base-content/50">
          {@feature.description}
        </p>
      </div>
    </div>
    """
  end

  def usage_card(assigns) do
    ~H"""
    <div class="card bg-base-100 border border-base-300 shadow-sm">
      <div class="card-body p-4">
        <h3 class="font-medium text-sm">{format_key(@feature.key)}</h3>
        <p class="text-xs text-base-content/50">{@feature.value || "—"}</p>
      </div>
    </div>
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
