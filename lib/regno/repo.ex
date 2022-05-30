defmodule Regno.Repo do
  use Ecto.Repo,
    otp_app: :regno,
    adapter: Ecto.Adapters.SQLite3
end
