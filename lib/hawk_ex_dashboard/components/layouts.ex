defmodule HawkExDashboard.Layouts do
  @moduledoc false
  use HawkExDashboard.HTML
  import HawkExDashboard.Nav


  attr(:current_path, :any, default: nil)
  slot(:inner_block, required: true)

  def app(assigns) do
    ~H"""
    <div class="drawer lg:drawer-open">
      <input id="drawer-toggle" type="checkbox" class="drawer-toggle" />
      <div class="drawer-side">
        <label for="drawer-toggle" class="drawer-overlay"></label>
        <.sidebar current_path={@current_path} />

      </div>
      <main class="drawer-content flex flex-col p-6">

        {render_slot(@inner_block)}
      </main>
    </div>
    """
  end

  def root(assigns) do
    ~H"""
    <!DOCTYPE html>
    <html lang="en" data-theme="hawk_ex_light">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <meta name="csrf-token" content={Phoenix.Controller.get_csrf_token()} />
        <.live_title default="hawk_ex Dashboard" suffix=" | hawk_ex Dashboard" phx-no-format>
          {assigns[:page_title]}
        </.live_title>
        <link rel="icon" href="/hawk_ex/assets/images/logo.png" />
        <link rel="stylesheet" href="/hawk_ex/assets/css/app.css" />
        <script defer type="text/javascript" src="/hawk_ex/assets/js/app.js"></script>
      </head>
      <body class="bg-base-200 min-h-screen">
        {@inner_content}
      </body>
    </html>
    """
  end
end
