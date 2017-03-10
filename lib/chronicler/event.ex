defmodule Chronicler.Event do
  use Ecto.Schema

  schema "events" do
    field :event, :string
    field :aggregate_id, :binary_id
    field :data, :map
    timestamps()
  end

end
