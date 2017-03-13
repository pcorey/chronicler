defmodule Chronicler.Aggregate do
  use GenServer

  import Ecto.Query

  alias Chronicler.Aggregate
  alias Chronicler.Event
  alias Chronicler.EventRepo

  @timeout 3000

  defmacro __using__(_opts) do
    IO.puts("using")
    quote do
      def get(id) do
        Aggregate.get(id, __MODULE__)
      end
    end
  end

  def start_link(aggregate_id, module) do
    IO.puts("starting #{aggregate_id}")
    GenServer.start_link(__MODULE__, {nil, 0, struct(module)}, name: {
      :via, Registry, {Aggregate.Registry, aggregate_id}
    })
  end

  def get_pid(aggregate_id, module) do
    case Registry.lookup(Aggregate.Registry, aggregate_id) do
      [{pid, _}] -> {:ok, pid}
      [] -> Supervisor.start_child(Aggregate.Supervisor, [aggregate_id, module])
    end
  end

  def get(aggregate_id, module) do
    {:ok, pid} = get_pid(aggregate_id, module)
    GenServer.call(pid, {:get, aggregate_id, module})
  end

  defp apply_new_events(module, version, state, []), do: {version, state}
  defp apply_new_events(module, version, state, events) do
    new_state = events
    |> Enum.map(fn
      %{event: event, version: version, aggregate_id: aggregate_id, data: data} ->
        {String.to_atom(event), version, aggregate_id, data}
    end)
    |> Enum.reduce(state, fn
      (event, state) -> apply(module, :apply_event, [event, state])
    end)

    {List.last(events).id, new_state}
  end

  defp bump_timer(timer) do
    case timer do
      nil -> Process.send_after(self, :timeout, @timeout)
      _ -> Process.cancel_timer(timer)
      Process.send_after(self, :timeout, @timeout)
    end
  end

  def handle_call({:get, aggregate_id, module}, _from, {timer, version, state}) do
    events = Event
    |> where(aggregate_id: ^aggregate_id)
    |> where([event], event.id > ^version)
    |> order_by([event], event.id)
    |> EventRepo.all

    {new_version, new_state} = apply_new_events(module, version, state, events)
    new_timer = bump_timer(timer)

    {:reply, new_state, {new_timer, new_version, new_state}}
  end


  def handle_info(:timeout, {timer, version, state}) do
    {:stop, :normal, []}
  end

end
