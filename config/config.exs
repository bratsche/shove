use Mix.Config

config :shove,
  apns: [
    certfile: "",
    enabled: false,
    timeout: 10000
  ]

import_config "#{Mix.env}.exs"
