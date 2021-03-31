# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     PersonalBoardV2.Repo.insert!(%PersonalBoardV2.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

import Ecto.Query, warn: false
alias PersonalBoardV2.Actors.{Board, List}
alias PersonalBoardV2.Repo

title = "Things To Be Done"

PersonalBoardV2.Board.create_board(%{
  title: title,
  img_url:
    "https://www.israel21c.org/wp-content/uploads/2018/07/israel-sunset-ashkelon-september.jpg"
})

query =
  Ecto.Query.from(b in Board,
    where: b.title == ^title,
    limit: 1
  )

board = Repo.one(query)

[
  %List{title: "In Progress", board_id: board.id, position: 1},
  %List{title: "Upcoming", board_id: board.id, position: 0},
  %List{title: "Done", board_id: board.id, position: 2}
]
|> Enum.each(fn params -> Repo.insert!(params) end)
