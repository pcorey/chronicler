defmodule Chronicler do
  @moduledoc """
  Documentation for Chronicler.
  """

  @doc """
  Command handler.
  """
  def handle(command), do: Chronicler.Command.handle(command)
end
