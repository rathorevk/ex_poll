import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ex_poll, ExPollWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "kspUjlNuJS5qYjoly9SKLdcOrSTa616FJOGP1At2/3SFf++5L/vZybMTzdbYgCOg",
  server: false

# In test we don't send emails.
config :ex_poll, ExPoll.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Configures PubSub
config :ex_poll, :pubsub_client, ExPoll.TestPubSub
