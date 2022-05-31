defmodule Disnote.Discord.Command do
  @moduledoc """
  Defines a Floofcatcher command
  """

  @doc """
  Called when registering a new command
  """
  @callback register() :: :ok | {:error, String.t()}
end
