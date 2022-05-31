defmodule Disnote.Discord.Command.Help do
  @behaviour Nosedrum.ApplicationCommand

  alias Nostrum.Api

  @impl true
  def usage, do: ["help"]

  @impl true
  def description, do: "Here to help!"

  @impl true
  def predicates, do: []

  @impl true
  def command(msg, _args) do
    {:ok, _msg} = Api.create_message(msg.channel_id, "?")
  end
end
