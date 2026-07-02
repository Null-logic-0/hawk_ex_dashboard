defmodule HawkExDashboard.EventsLive do
  use Phoenix.LiveView
  use HawkExDashboard.HTML
  import HawkExDashboard.{PageHeading, Table, JSONViewer}

  alias HawkEx.Events

  @max_events 100
  @buffer_limit 99

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Events.subscribe()

    socket =
      socket
      |> assign(:page_title, "Events")
      |> assign(:current_path, "/hawk_ex/events")
      |> assign(:paused, false)
      |> assign(:buffer_count, 0)
      |> assign(:filter_type, "all")
      |> stream(:events, [])
      |> assign(:event_buffer, [])
      |> assign(:event_count, 0)
      |> assign(:compact, false)

    {:ok, socket}
  end

  @impl true
  def handle_info({Events, event_name, payload}, socket) do
    if socket.assigns.paused do
      count = min(socket.assigns.buffer_count + 1, @buffer_limit)
      {:noreply, assign(socket, :buffer_count, count)}
    else
      event = build_event(event_name, payload)
      buffer = [event | socket.assigns.event_buffer] |> Enum.take(@max_events)

      socket =
        socket
        |> assign(:event_buffer, buffer)

      if passes_filter?(event, socket.assigns.filter_type) do
        {:noreply,
         socket
         |> assign(:event_count, socket.assigns.event_count + 1)
         |> stream_insert(:events, event, at: 0, limit: @max_events)}
      else
        {:noreply, socket}
      end
    end
  end

  @impl true
  def handle_event("pause", _params, socket) do
    {:noreply, assign(socket, :paused, true)}
  end

  def handle_event("resume", _params, socket) do
    {:noreply,
     socket
     |> assign(:paused, false)
     |> assign(:buffer_count, 0)}
  end

  def handle_event("filter_type", %{"type" => type}, socket) do
    matching =
      socket.assigns.event_buffer
      |> Enum.filter(&passes_filter?(&1, type))
      |> Enum.take(@max_events)

    socket =
      socket
      |> assign(:filter_type, type)
      |> assign(:event_count, length(matching))
      |> stream(:events, matching, reset: true)

    {:noreply, socket}
  end

  defp build_event(event_name, payload) do
    %{
      id: System.unique_integer([:positive, :monotonic]) |> to_string(),
      name: event_name,
      account_id: Map.get(payload, :account_id),
      payload_json: Jason.encode!(payload, pretty: true),
      timestamp: DateTime.utc_now()
    }
  end

  defp passes_filter?(_event, "all"), do: true
  defp passes_filter?(event, type), do: String.starts_with?(event.name, type)

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app current_path={@current_path}>
      <div class="flex items-center justify-between mb-6">
        <.heading title={@page_title} />

        <div class="flex items-center gap-4">
          <div class="flex items-center gap-1.5 text-sm">
            <span :if={!@paused} class="relative flex h-2 w-2">
              <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-success opacity-75"></span>
              <span class="relative inline-flex rounded-full h-2 w-2 bg-success"></span>
            </span>
            <span class={["animate-pulse",@paused && "text-error", !@paused && "text-success"]}>
              {if @paused, do: "Paused", else: "Live"}
            </span>
          </div>

          <button
            :if={@paused && @buffer_count > 0}
            phx-click="resume"
            class="badge badge-warning gap-2 cursor-pointer"
          >
            {if @buffer_count >= 99, do: "99+", else: @buffer_count} new
          </button>

          <form phx-change="filter_type" class="contents">
            <select name="type" class="select select-bordered select-sm">
              <option value="all">All types</option>
              <option value="subscription">subscription.*</option>
              <option value="csv">csv.*</option>
              <option value="audit">audit.*</option>
            </select>
          </form>

          <button
            phx-click={if @paused, do: "resume", else: "pause"}
            class={["btn btn-sm", @paused && "btn-success", !@paused && "btn-error"]}
          >
            {if @paused, do: "Resume", else: "Pause"}
          </button>
        </div>
      </div>

      <.table
        id="events-table"
        stream={@streams.events}
        compact={@compact}
        show_search={false}
        loading={false}
        empty_title="Waiting for events…"
        empty_message="Events emitted by your app via HawkEx.Events will appear here in real time."
      >
        <:col :let={event} label="Event">
          <span class="badge badge-primary badge-sm font-mono-data">{event.name}</span>
        </:col>
        <:col :let={event} label="Account">
          <span class="font-mono-data text-xs">{event.account_id || "system"}</span>
        </:col>
        <:col :let={event} label="Time">
          <span class="font-mono-data text-xs text-base-content/60">
            {format_dt(event.timestamp)}
          </span>
        </:col>
        <:col :let={event} label="Payload">
          <button
            class="btn btn-ghost btn-xs font-mono-data"
            phx-click={JS.toggle(to: "#payload-#{event.id}")}
          >
            JSON
          </button>
          <div id={"payload-#{event.id}"} class="hidden mt-2">
              <.json_viewer id={"json-#{event.id}"} data={Jason.decode!(event.payload_json)} />
          </div>

        </:col>
      </.table>
    </Layouts.app>
    """
  end
end
