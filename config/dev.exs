import Config

# Dev database
config :hawk_ex_dashboard, HawkExDev.Repo,
  database: "hawk_ex_dashboard_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  pool_size: 10

# Tell hawk_ex to use the dev repo and a dummy account schema
config :hawk_ex,
  repo: HawkExDev.Repo,
  account_schema: HawkExDev.FakeAccount

# Phoenix endpoint
config :hawk_ex_dashboard, HawkExDev.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4000],
  adapter: Bandit.PhoenixAdapter,
  server: true,
  live_view: [signing_salt: "hawk_ex_dev_salt"],
  secret_key_base: String.duplicate("dev_secret_key_base_not_for_prod", 2),
  pubsub_server: HawkExDev.PubSub

# Hawk PubSub
config :hawk_ex, pubsub: HawkExDev.PubSub

# Logger
config :logger, level: :debug
