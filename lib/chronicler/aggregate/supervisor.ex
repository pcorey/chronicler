defmodule Chronicler.Aggregate.Supervisor do
  use Supervisor
  alias Chronicler.Aggregate

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    children = [
      worker(Aggregate, [], restart: :transient)
    ]
    supervise(children, strategy: :simple_one_for_one)
  end

end
