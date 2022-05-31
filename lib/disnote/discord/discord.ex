defmodule Disnote.Discord do
  @moduledoc """
  Discord service, handles incoming events
  """
  use Nostrum.Consumer
  require Logger

  alias Nostrum.Api
  alias Disnote.Discord.Handler.{
    Ready,
    VoiceStateUpdate
  }

  alias Disnote.Discord.Command
  alias Nosedrum.Storage.ETS, as: CommandStorage
  alias Nostrum.Struct.Interaction
  alias Nostrum.Struct.Message
  alias Nostrum.Struct.Component

  def start_link do
    Consumer.start_link(__MODULE__, max_restarts: 0)
  end

  def handle_event({:READY, _data, _ws_state}) do
    Ready.handle()
  end

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    # MessageCreate.handle(msg)
    Logger.debug("Received message: " <> msg.content)
  end

  def handle_event({:VOICE_STATE_UPDATE, state, _ws_state}) do
    VoiceStateUpdate.handle(state)
  end

  def handle_event({:INTERACTION_CREATE, %Interaction{data: %{component_type: 2, custom_id: type}} = interaction, _ws_state}) do
    Logger.debug("Handing note show")
    case String.split(type, "-") do
      ["pin_note"] ->
        case interaction.message.pinned do
          false ->
            Nostrum.Api.add_pinned_channel_message(interaction.channel_id, interaction.message.id)
            Nostrum.Api.create_interaction_response(interaction, %{type: 6})
          true ->
            Nostrum.Api.delete_pinned_channel_message(interaction.channel_id, interaction.message.id)
            Nostrum.Api.create_interaction_response(interaction, %{type: 6})
        end
      ["show_note_modal"] ->
        current_text = interaction.message.embeds |> Enum.fetch!(0) |> Map.get(:description)

        Nostrum.Api.create_interaction_response(interaction, %{type: 9, data: %{
          custom_id: "edit_note_modal-" <> Integer.to_string(interaction.message.id),
          title: "Edit note",
          components: [
            %{
              type: 1,
              components: [
                #%{type: 2, label: "📝 Edit", custom_id: "show_note_modal", style: 1}
                %{type: 4, custom_id: "update_note", label: "📝 Edit", style: 2, max_length: 4000, value: current_text}
              ]
            }
          ]
        }})
      other ->
        IO.inspect(other)
    end
  end

  def handle_event({:INTERACTION_CREATE, %Interaction{data: %{custom_id: type}, type: 5} = interaction, _ws_state}) do
    Logger.debug("Handing note edit")
    case String.split(type, "-") do
      ["edit_note_modal", id] ->
        Logger.debug("should update")
        IO.inspect(id)
        new_text = interaction.data.components |> Enum.fetch!(0) |> Map.get(:components) |> Enum.fetch!(0) |> Map.get(:value)

        Nostrum.Api.edit_message!(interaction.channel_id, String.to_integer(id), %{ embeds: [
          %{
            type: "rich",
            title: "note",
            description: new_text,
            color: 0x00FFFF
          }
        ]})

        Nostrum.Api.create_interaction_response(interaction, %{type: 6})
      other ->
        IO.inspect(other)
    end
  end

  def handle_event({:INTERACTION_CREATE, %Interaction{data: %{name: name}} = interaction, _ws_state}) do

    #Nostrum.Api.create_interaction_response!(interaction, %{type: 5})

    Logger.debug("Handing note create")
    case name do
      "help" ->
        Logger.debug("Someone asked for help")
      "note" ->
        Nostrum.Api.create_interaction_response(interaction, %{type: 4, data: %{
          content: "",
          embeds: [
            %{
              type: "rich",
              title: "note",
              description: "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
              color: 0x00FFFF
            }
          ],
          components: [
            %{
              type: 1,
              components: [
                %{type: 2, label: "📝 Edit", custom_id: "show_note_modal", style: 1},
                %{type: 2, label: "📌 Pin/Unpin me", custom_id: "pin_note", style: 2}
                #%{type: 4, custom_id: "update_note", label: "📝 Edit", style: 2, max_length: 4000, placeholder: "nothing here 👻"}
              ]
            }
          ]
        }})
      _ -> IO.inspect(interaction)
    end
  end

  def handle_event({:INTERACTION_CREATE, payload, _ws_state}) do
    IO.inspect(payload)
  end

  def handle_event(_event) do
    :noop
  end
end
