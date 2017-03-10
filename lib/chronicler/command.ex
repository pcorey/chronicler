defmodule Chronicler.Command do
  use GenServer
  require Logger
  alias Chronicler.Event
  alias Chronicler.Listener
  import Enum, only: [map: 2]

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def handle(command) do
    GenServer.call(__MODULE__, {:handle, command})
  end

  def store_event({type, aggregate_id, data}) do
    %Event{
      event: Atom.to_string(type),
      aggregate_id: aggregate_id,
      data: data
    }
    |> Chronicler.EventRepo.insert
  end

  def handle_event({event, aggregate_id, data}) do
    Registry.dispatch(Listener.Registry, event, fn entries ->
      for {pid, module} <- entries do
        if Process.alive?(pid), do: GenServer.call(pid, {:event,
                                                         module,
                                                         event,
                                                         aggregate_id,
                                                         data})
      end
    end)
    {event, aggregate_id, data}
  end

  def handle_call({:handle, command = %module{}}, _from, []) do
    Logger.debug("Handling #{inspect command}.")
    with {:ok, events} <- apply(module, :handle, [command])
    do
      events
      |> map(&handle_event/1)
      |> map(&store_event/1)
      {:reply, {:ok}, []}
    else
      {:error, error} -> {:reply, {:error, error}, []}
      error           -> {:reply, {:error, error}, []}
    end
  end

end
