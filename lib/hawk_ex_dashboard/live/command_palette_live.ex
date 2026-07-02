defmodule HawkExDashboard.CommandPaletteLive do
  use Phoenix.LiveComponent
  use HawkExDashboard.HTML

  alias HawkEx.{Billing, Audit, CSV}

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> assign(:open, false)
     |> assign(:query, "")
     |> assign(:results, %{subscriptions: [], audit: [], exports: []})
     |> assign(:selected_index, 0)}
  end

  @impl true
  def handle_event("open", _params, socket) do
    {:noreply, assign(socket, open: true, query: "", results: empty_results())}
  end

  def handle_event("close", _params, socket) do
    {:noreply, assign(socket, open: false, query: "")}
  end

  def handle_event("search", %{"query" => query}, socket) do
    results =
      if String.length(query) >= 2 do
        %{
          subscriptions: Billing.search_subscriptions(query, limit: 4),
          audit: Audit.search(query, limit: 4),
          exports: CSV.search_exports(query, limit: 4)
        }
      else
        empty_results()
      end

    {:noreply,
     socket
     |> assign(:query, query)
     |> assign(:results, results)
     |> assign(:selected_index, 0)}
  end

  defp empty_results do
    %{subscriptions: [], audit: [], exports: []}
  end

  defp has_results?(results) do
    results.subscriptions != [] ||
      results.audit != [] ||
      results.exports != []
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id}>
      <div
        id={"#{@id}-listener"}
        phx-hook="CommandPalette"
        phx-target={@myself}
        data-open={to_string(@open)}
      />

      <dialog class={["modal", @open && "modal-open"]}>
        <div class="modal-box max-w-lg p-0">

          <%!-- Search input --%>
          <div class="flex items-center gap-3 p-4 border-b border-base-300">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-base-content/40 shrink-0"
              fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
              <path stroke-linecap="round" stroke-linejoin="round"
                d="M21 21l-5.197-5.197m0 0A7.5 7.5 0 105.196 5.196a7.5 7.5 0 0010.607 10.607z" />
            </svg>
            <form phx-change="search" phx-target={@myself} class="flex-1">
              <input
                id={"#{@id}-input"}
                type="search"
                name="query"
                value={@query}
                placeholder="Search accounts, audit logs, exports…"
                class="input input-sm text-sm"
                phx-debounce="150"
                autocomplete="off"
              />
            </form>
            <kbd class="kbd kbd-sm opacity-40">Esc</kbd>
          </div>

          <%!-- Results --%>
          <div class="max-h-96 overflow-y-auto p-4">
            <div :if={@query == ""} class="px-4 py-8 text-center text-sm text-base-content/40">
              Start typing to search…
            </div>

            <div :if={@query != "" && !has_results?(@results)}
              class="px-4 py-8 text-center text-sm text-base-content/40">
              No results for "{@query}"
            </div>

            <%!-- Subscriptions --%>
            <div :if={@results.subscriptions != []}>
              <p class="px-4 py-1.5 text-xs font-medium text-base-content/40 uppercase tracking-wide">
                Subscriptions
              </p>
              <.link
                :for={sub <- @results.subscriptions}
                navigate={"/hawk_ex/billing?drawer=#{sub.id}"}
                class="flex items-center justify-between px-4 py-2.5 hover:bg-base-200 transition-colors"
                phx-click="close"
                phx-target={@myself}
              >
                <div class="flex items-center gap-2">
                  <span class="font-mono-data text-xs text-base-content/60">
                    {String.slice(sub.account_id, 0, 8)}…
                  </span>
                  <span class="badge badge-primary badge-xs">{sub.plan.display_name}</span>
                </div>
                <span class={[
                  "badge badge-xs",
                  sub.status == "active" && "badge-success",
                  sub.status == "trialing" && "badge-warning"
                ]}>
                  {sub.status}
                </span>
              </.link>
            </div>

            <%!-- Audit logs --%>
            <div :if={@results.audit != []}>
              <p class="px-4 py-1.5 text-xs font-medium text-base-content/40 uppercase tracking-wide">
                Audit Events
              </p>
              <.link
                :for={log <- @results.audit}
                navigate={"/hawk_ex/audit?search=#{log.action}"}
                class="flex items-center justify-between px-4 py-2.5 hover:bg-base-200 transition-colors"
                phx-click="close"
                phx-target={@myself}
              >
                <span class="badge badge-neutral badge-sm font-mono-data">{log.action}</span>
                <span class="text-xs text-base-content/40">{format_dt(log.inserted_at)}</span>
              </.link>
            </div>

            <%!-- CSV exports --%>
            <div :if={@results.exports != []}>
              <p class="px-4 py-1.5 text-xs font-medium text-base-content/40 uppercase tracking-wide">
                CSV Exports
              </p>
              <.link
                :for={export <- @results.exports}
                navigate={"/hawk_ex/csv"}
                class="flex items-center justify-between px-4 py-2.5 hover:bg-base-200 transition-colors"
                phx-click="close"
                phx-target={@myself}
              >
                <span class="badge badge-ghost badge-sm">{export.export_type}</span>
                <span class={[
                  "badge badge-xs",
                  export.status == "completed" && "badge-success",
                  export.status == "failed" && "badge-error",
                  export.status == "pending" && "badge-warning"
                ]}>
                  {export.status}
                </span>
              </.link>
            </div>
          </div>

          <%!-- Footer --%>
          <div class="flex items-center gap-4 p-4 border-t border-base-300 text-xs text-base-content/30">
            <span><kbd class="kbd kbd-xs">↵</kbd> select</span>
            <span><kbd class="kbd kbd-xs">Esc</kbd> close</span>
            <span><kbd class="kbd kbd-xs">⌘K</kbd> toggle</span>
          </div>
        </div>

        <%!-- Backdrop --%>
        <div class="modal-backdrop" phx-click="close" phx-target={@myself}></div>
      </dialog>
    </div>
    """
  end
end
