defmodule HawkExDashboard.AccountPicker do
  @moduledoc false
  use HawkExDashboard.HTML

  attr(:accounts, :list, required: true)
  attr(:selected_id, :string, default: nil)

  use HawkExDashboard.HTML

  def account_picker(assigns) do
    ~H"""
    <form phx-change="select_account" class="mb-6">
          <label class="text-sm text-base-content/60 block mb-2">Account</label>
          <select name="account_id" class="select select-bordered w-full max-w-sm">
            <option value="">Select an account…</option>
            <option :for={id <- @accounts} value={id} selected={id == @selected_id}>
              {id}
            </option>
          </select>
    </form>

    """
  end
end
