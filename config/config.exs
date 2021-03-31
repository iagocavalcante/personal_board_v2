# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :personal_board_v2,
  ecto_repos: [PersonalBoardV2.Repo]

# Configures the endpoint
config :personal_board_v2, PersonalBoardV2Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "pzX6jX2fJRjHBy9JhGJp+bHRjoritI4TeWGR0cTCmFOt6thqPxaoa2QziSa1QFAl",
  render_errors: [view: PersonalBoardV2Web.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: PersonalBoardV2.PubSub,
  live_view: [signing_salt: "ITsMgoSm"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
