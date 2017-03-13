defmodule Chronicler.Event do
  use Ecto.Schema

  schema "events" do
    field :event, :string
    field :version, :integer
    field :aggregate_id, :binary_id
    field :data, :map
    timestamps()
  end

end
