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

  def register_listener(module), do: register_listener(module, :on)
  def register_listener(module, function) do
    GenServer.call(__MODULE__, {:register_listener, module, function})
  end

  def store_event({event, version, aggregate_id, data}) do
    %Event{
      event: Atom.to_string(event),
      version: version,
      aggregate_id: aggregate_id,
      data: data
    }
    |> Chronicler.EventRepo.insert
    {event, aggregate_id, data}
  end

  def handle_event({event, aggregate_id, data}, listeners) do
    listeners
    |> Enum.map(fn
      {module, function} -> Task.async(module, function, [event, aggregate_id, data])
    end)
  end

  def handle_call({:handle, command = %module{}}, _from, listeners) do
    Logger.debug("Handling #{inspect command}.")
    with {:ok, events} <- apply(module, :handle, [command])
    do
      events
      |> map(&store_event/1)
      |> map(&(handle_event(&1, listeners)))
      |> List.flatten
      |> Task.yield_many
      {:reply, {:ok}, listeners}
    else
      {:error, error} -> {:reply, {:error, error}, listeners}
      error           -> {:reply, {:error, error}, listeners}
    end
  end

  def handle_call({:register_listener, module, function}, _from, listeners) do
    new_listeners = listeners ++ [{module, function}]
    {:reply, {:ok, new_listeners}, new_listeners}
  end

end
