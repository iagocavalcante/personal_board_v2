defmodule PersonalBoardV2.Repo do
  use Ecto.Repo,
    otp_app: :personal_board_v2,
    adapter: Ecto.Adapters.Postgres
end
