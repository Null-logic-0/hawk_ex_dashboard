defmodule HawkExDashboard.JSONViewer do
  @moduledoc false
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  attr(:id, :string, required: true)
  attr(:data, :any, required: true)

  def json_viewer(assigns) do
    json = Jason.encode!(assigns.data, pretty: true)
    assigns = assign(assigns, :highlighted, highlight(json))

    ~H"""
    <div class="relative group font-mono-data">
      <button
        id={"#{@id}-copy"}
        class="absolute top-2 right-2 btn btn-ghost btn-xs sm:opacity-0 opacity-100 group-hover:opacity-100 transition-opacity"
        title="Copy to clipboard"
        phx-click={
          JS.dispatch("hawk_ex:copy",
            detail: %{text: Jason.encode!(@data, pretty: true)}
          )
        }
      >
        <svg xmlns="http://www.w3.org/2000/svg" class="h-3.5 w-3.5" fill="none"
          viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
          <path stroke-linecap="round" stroke-linejoin="round"
            d="M15.666 3.888A2.25 2.25 0 0013.5 2.25h-3c-1.03 0-1.9.693-2.166 1.638m7.332 0c.055.194.084.4.084.612v0a.75.75 0 01-.75.75H9a.75.75 0 01-.75-.75v0c0-.212.03-.418.084-.612m7.332 0c.646.049 1.288.11 1.927.184 1.1.128 1.907 1.077 1.907 2.185V19.5a2.25 2.25 0 01-2.25 2.25H6.75A2.25 2.25 0 014.5 19.5V6.257c0-1.108.806-2.057 1.907-2.185a48.208 48.208 0 011.927-.184" />
        </svg>
      </button>

      <pre
        id={"#{@id}-pre"}
        class="bg-base-200 rounded-lg p-4 overflow-x-auto text-xs leading-relaxed"
      >{Phoenix.HTML.raw(@highlighted)}</pre>
    </div>
    """
  end

  defp highlight(json) do
    json
    |> Phoenix.HTML.html_escape()
    |> Phoenix.HTML.safe_to_string()
    |> String.replace(~r/"([^"]+)":/, "<span class=\"text-accent\">\"\\1\"</span>:")
    |> String.replace(~r/: "([^"]*)"/, ": <span class=\"text-success\">\"\\1\"</span>")
    |> String.replace(~r/: (\d+\.?\d*)/, ": <span class=\"text-warning\">\\1</span>")
    |> String.replace(~r/: (true|false)/, ": <span class=\"text-info\">\\1</span>")
    |> String.replace(~r/: (null)/, ": <span class=\"text-base-content/40\">\\1</span>")
  end
end
