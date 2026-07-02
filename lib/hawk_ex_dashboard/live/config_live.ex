defmodule HawkExDashboard.ConfigLive do
  use Phoenix.LiveView
  use HawkExDashboard.HTML
  import HawkExDashboard.{PageHeading, ConfigRow}

  alias HawkEx.Config

  @path "/hawk_ex/configuration"

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Configuration")
      |> assign(:current_path, @path)
      |> assign(:config, Config.snapshot())

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app current_path={@current_path}>
      <div class="flex items-center justify-between mb-2">
        <.heading title={@page_title} />
        <span class="badge badge-secondary">read-only</span>
      </div>

      <div class="card bg-base-100 border border-base-300 shadow-sm mb-6">
        <div class="card-body p-1">
          <dl class="divide-y divide-base-300">
            <.config_row label="Account schema" value={format_module(@config.account_schema)} />
            <.config_row label="Database repo" value={format_module(@config.repo)} />
            <.config_row label="PubSub" value={format_module(@config.pubsub)} />
            <.config_row label="Oban" value={format_module(@config.oban)} />
            <.config_row label="CSV storage" value={format_csv_storage(@config.csv_storage)} />
          </dl>
        </div>
      </div>

      <p class="text-xs text-base-content/40  text-center">
        HAWK_EX Dashboard ·
        <a href="https://hexdocs.pm/hawk_ex_dashboard" class="link link-hover" target="_blank">
          Documentation
        </a>
      </p>
    </Layouts.app>
    """
  end

  defp format_module(nil), do: "Not set"

  defp format_module(mod) when is_atom(mod),
    do: mod |> to_string() |> String.replace("Elixir.", "")

  defp format_csv_storage(nil), do: "Not set"

  defp format_csv_storage({adapter, opts}) do
    adapter_name = adapter |> to_string() |> String.replace("Elixir.", "")
    opts_str = opts |> Enum.map(fn {k, v} -> "#{k}: #{inspect(v)}" end) |> Enum.join(", ")
    "#{adapter_name} (#{opts_str})"
  end
end
