defmodule HawkExDashboard.Search do
  @moduledoc false
  use HawkExDashboard.HTML

  attr(:search, :string, default: "")
  attr(:search_placeholder, :string, default: "Search…")
  attr(:show_search, :boolean, default: true)

  def search(assigns) do
    ~H"""
    <form :if={@show_search} phx-change="table_search" class="contents">
      <label class="input input-bordered input-sm flex items-center gap-2 bg-base-200 max-w-full">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 opacity-50" fill="none"
          viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
          <path stroke-linecap="round" stroke-linejoin="round"
            d="M21 21l-5.197-5.197m0 0A7.5 7.5 0 105.196 5.196a7.5 7.5 0 0010.607 10.607z" />
        </svg>
        <input
          type="search"
          name="search"
          value={@search}
          placeholder={@search_placeholder}
          class="grow text-sm"
          phx-debounce="250"
          autocomplete="off"
        />
      </label>
    </form>
    <div :if={!@show_search} class="flex-1"></div>
    """
  end
end
