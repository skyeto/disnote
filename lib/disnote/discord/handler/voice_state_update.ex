defmodule Disnote.Discord.Handler.VoiceStateUpdate do
  require Logger

  alias Nostrum.Api

  def handle(%Nostrum.Struct.Event.VoiceState{channel_id: nil} = state) do
    case Cachex.exists?(:user_voice, state.user_id) do
      {:ok, true} ->
        %{id: old_channel} = Cachex.get!(:user_voice, state.user_id)
        delete_channel!(old_channel)
      _ ->
        :ok
    end
  end

  def handle(%Nostrum.Struct.Event.VoiceState{channel_id: 979457807537537114} = state) do
    case state.channel_id == 979457807537537114 do
      true ->
        {:ok, channel} = Api.create_guild_channel(state.guild_id, name: state.member.user.username <> "'s channel", type: 2, parent_id: 979457885086027846)

        {:ok, _} = Cachex.put(:user_voice, state.user_id, %{id: channel.id, timestamp: DateTime.utc_now()})
        Api.modify_guild_member(state.guild_id, state.member.user.id, channel_id: channel.id)
      false ->
        :ok
    end
  end

  def handle(%Nostrum.Struct.Event.VoiceState{channel_id: id} = state) do
    case Cachex.exists?(:user_voice, state.user_id) do
      {:ok, true} ->
        %{id: old_channel, timestamp: time} = Cachex.get!(:user_voice, state.user_id)

        if DateTime.diff(DateTime.utc_now(), time) > 5 do
          delete_channel!(old_channel)
        end
      _ ->
        :ok
    end
  end

  defp is_channel_temp?(channel_id) do
    case Api.get_channel(channel_id) do
      {:ok, channel} ->
        channel.parent_id == 979457885086027846
      _ ->
        false
    end
  end

  defp delete_channel!(channel_id) do
    case is_channel_temp?(channel_id) do
      true ->
        Api.delete_channel!(channel_id)
      false ->
        :ok
    end
  end


end
