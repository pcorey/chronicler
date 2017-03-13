defmodule Chronicler.EventRepo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :event, :string
      add :version, :integer
      add :aggregate_id, :uuid
      add :data, :map
      timestamps()
    end
  end

end
