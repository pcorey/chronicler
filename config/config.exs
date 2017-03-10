use Mix.Config

config :logger,
  backends: [:console],
  compile_time_purge_level: :info,
  level: :info

config :chronicler, ecto_repos: [Chronicler.EventRepo]

config :chronicler, Chronicler.EventRepo,
  adapter: Ecto.Adapters.Postgres,
  database: "event_store",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: "5432"

import_config "#{Mix.env}.exs"

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure for your application as:
#
#     config :chronicler, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:chronicler, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"
