defmodule Disnote.Discord.Handler.Ready do
  alias Nosedrum.Storage.ETS, as: CommandStorage
  alias Nostrum.Api
  require Logger

  @commands %{
    "help" => %{
      name: "help",
      description: "help!",
      options: %{}
    },

    "new_note" => %{
      name: "note",
      description: "Create a new note",
      options: %{}
    }
  }

  def handle() do
    :ok = load_commands()
    :ok = Api.update_status(:online, "your notes | /note", 3)
  end

  defp load_commands do
    Logger.debug("Creating commands")


    [@commands]
    |> Stream.concat()
    |> Enum.each(fn {name, command} -> Nostrum.Api.create_guild_application_command(979315337331900437, 978358000936951848, command) end)

    #[@commands]
    #|> Stream.concat()
    #|> Enum.each(fn {name, cog} -> CommandStorage.add_command([name], cog) end)
  end
end
