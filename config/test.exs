use Mix.Config

config :logger,
  level: :debug

config :chronicler, Chronicler.EventRepo,
  adapter: Ecto.Adapters.Postgres,
  database: "events",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: "5432",
  pool: Ecto.Adapters.SQL.Sandbox
