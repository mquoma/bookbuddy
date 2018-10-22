# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :book_buddy,
  ecto_repos: [BookBuddy.Repo]

# Configures the endpoint
config :book_buddy, BookBuddyWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "EABEzz4l60hsuuyLuk5doMGiWIi7wd3ZCBYqB1FnU5gdz/yM3RLexhjBRSBEh3dE",
  render_errors: [view: BookBuddyWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: BookBuddy.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
