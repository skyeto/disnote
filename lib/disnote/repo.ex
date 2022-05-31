defmodule Disnote.Repo do
  use Ecto.Repo,
    otp_app: :disnote,
    adapter: Ecto.Adapters.Postgres
end
