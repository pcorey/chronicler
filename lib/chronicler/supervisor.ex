defmodule Chronicler.Supervisor do
  use Supervisor
  alias Chronicler.{Aggregate, Command, EventRepo, Listener}
  require Logger

  def start(_type, _args) do
    start_link()
  end

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    children = [
      supervisor(EventRepo, []),
      supervisor(Aggregate.Supervisor, []),
      supervisor(Registry, [:unique, Aggregate.Registry], id: :aggregate_registry),
      supervisor(Registry, [:duplicate, Listener.Registry], id: :listener_registry),
      worker(Command, []),
    ]
    supervise(children, strategy: :one_for_one)
  end

end
