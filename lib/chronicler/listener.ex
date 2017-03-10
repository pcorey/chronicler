defmodule Chronicler.Listener do

  defmacro __using__(_opts) do
    quote do
      use GenServer

      defp register_events(events) do
        events
        |> Enum.map(fn
          event -> Registry.register(Chronicler.Listener.Registry, event, __MODULE__)
        end)
      end

      def start_link(events) do
        GenServer.start_link(__MODULE__, events)
      end

      def init(events) do
        register_events(events)
        {:ok, events}
      end

      def handle_call({:event, module, event, aggregate_id, data}, _, state) do
        apply(module, :on, [event, aggregate_id, data])
        {:reply, :ok, state}
      end
    end
  end

end
