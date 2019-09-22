# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :prexent, PrexentWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "zVKZGqh1PgDS2O5nZIJwEQtmCeA+945A/PZdtwSDMl0rGvqwt9CKtvH+UT5RacqE",
  render_errors: [view: PrexentWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Prexent.PubSub, adapter: Phoenix.PubSub.PG2],
  reloadable_apps: [:prexent],
  live_view: [
    signing_salt: "gc8LvlKa8jwULPyGhlEmZkJNlDBOFvxLb3incF1dkIXsgxGDkOpXbaCyS1vyleED"
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
