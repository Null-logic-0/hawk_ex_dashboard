defmodule HawkExDashboard.HTML do
  @moduledoc """
  Shared imports/aliases for all HawkExDashboard LiveViews and
  function components. Use this instead of `use Phoenix.Component`
  directly, so CoreComponents (icon/1, etc.) and Nav are always
  available without per-file imports.
  """

  defmacro __using__(_opts) do
    quote do
      use Phoenix.Component

      import HawkExDashboard.Formatters

      import HawkExDashboard.JSONViewer

      alias HawkExDashboard.Layouts

      alias Phoenix.LiveView.JS
    end
  end
end
