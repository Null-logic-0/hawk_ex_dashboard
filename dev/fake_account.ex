defmodule HawkExDev.FakeAccount do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "fake_accounts" do
    field(:name, :string)
    timestamps(type: :utc_datetime)
  end
end
