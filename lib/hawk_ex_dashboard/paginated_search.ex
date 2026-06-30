defmodule HawkExDashboard.PaginatedSearch do
  @moduledoc """
  Shared pagination + search behavior for LiveViews using the
  HawkExDashboard.Table component with URL-backed page/search state.

  ## Usage

      defmodule MyLive do
        use Phoenix.LiveView
        use HawkExDashboard.PaginatedSearch, path: "/hawk_ex"

        @impl true
        def mount(_params, _session, socket) do
          {:ok,
           socket
           |> assign(:total_pages, 1)
           |> assign(:total_count, 0)
           |> assign(:loading, true)
           |> assign(:error, nil)
           |> stream(:my_rows, [])}
        end

        @impl true
        def handle_params(params, _uri, socket) do
          {:noreply, paginated_search_params(socket, params, &load_data/3)}
        end

        defp load_data(socket, page, search) do
          start_async(socket, :load_recent, fn ->
            MyContext.list(page: page, per_page: 20, search: search)
          end)
        end

        @impl true
        def handle_async(:load_recent, {:ok, page_result}, socket) do
          handle_paginated_result(socket, page_result, fn socket, result ->
            socket
            |> assign(:total_pages, result.total_pages)
            |> assign(:total_count, result.total_count)
            |> stream(:my_rows, result.entries, reset: true)
          end)
        end

        def handle_async(:load_recent, {:exit, reason}, socket) do
          {:noreply, assign(socket, error: "...", loading: false)}
        end
      end

  This injects:
    * `handle_event("table_page", ...)`
    * `handle_event("table_search", ...)`
    * `handle_event("table_retry", ...)` — requires the using module
      to define `load_data/3` (called as `load_data(socket, page, search)`)
    * Helper functions: `paginated_search_params/3`, `handle_paginated_result/4`
  """

  defmacro __using__(opts) do
    base_path = Keyword.fetch!(opts, :path)

    quote do
      import HawkExDashboard.PaginatedSearch,
        only: [
          parse_page: 1,
          build_path: 3,
          paginated_search_params: 3,
          handle_paginated_result: 4
        ]

      @paginated_search_path unquote(base_path)

      @impl true
      def handle_event("table_page", %{"page" => page}, socket) do
        {:noreply,
         Phoenix.LiveView.push_patch(socket,
           to: build_path(socket, @paginated_search_path, page: page)
         )}
      end

      def handle_event("table_search", %{"search" => search}, socket) do
        {:noreply,
         Phoenix.LiveView.push_patch(socket,
           to: build_path(socket, @paginated_search_path, page: 1, search: search)
         )}
      end

      def handle_event("table_retry", _params, socket) do
        socket = Phoenix.Component.assign(socket, loading: true, error: nil)
        {:noreply, load_data(socket, socket.assigns.page, socket.assigns.search)}
      end

      defoverridable handle_event: 3
    end
  end

  @doc false
  def parse_page(nil), do: 1

  def parse_page(page_str) do
    case Integer.parse(page_str) do
      {n, ""} when n > 0 -> n
      _ -> 1
    end
  end

  @doc false
  def build_path(socket, base_path, opts) do
    page = Keyword.get(opts, :page, socket.assigns[:page] || 1)
    search = Keyword.get(opts, :search, socket.assigns[:search] || "")

    query =
      %{}
      |> maybe_put("page", page, 1)
      |> maybe_put("search", search, "")
      |> URI.encode_query()

    if query == "", do: base_path, else: "#{base_path}?#{query}"
  end

  defp maybe_put(map, _key, value, default) when value in [default, nil], do: map
  defp maybe_put(map, key, value, _default), do: Map.put(map, key, to_string(value))

  @doc """
  Call from `handle_params/3`. Parses page/search from URL params,
  assigns them, and calls the given `load_fun.(socket, page, search)`
  to kick off data loading (typically an async load).
  """
  def paginated_search_params(socket, params, load_fun) do
    page = parse_page(params["page"])
    search = params["search"] || ""

    socket
    |> Phoenix.Component.assign(:page, page)
    |> Phoenix.Component.assign(:search, search)
    |> Phoenix.Component.assign(:loading, true)
    |> then(&load_fun.(&1, page, search))
  end

  @doc """
  Call from the success branch of `handle_async/3`. Given the loaded
  page_result (must have `:page` and `:total_pages` keys), either
  redirects to the last valid page if the requested page no longer
  exists (e.g. search narrowed results), or calls `assign_fun.(socket, result)`
  to apply the real data to assigns.
  """
  def handle_paginated_result(socket, base_path, page_result, assign_fun) do
    if page_result.page > page_result.total_pages and page_result.total_pages > 0 do
      {:noreply,
       Phoenix.LiveView.push_patch(socket,
         to: build_path(socket, base_path, page: page_result.total_pages)
       )}
    else
      socket = Phoenix.Component.assign(socket, :loading, false)
      {:noreply, assign_fun.(socket, page_result)}
    end
  end
end
