use Mix.Config

config :cint_api, CintApi,
  url: "https://cdp.cintworks.net/"

config :cint_api, email: [
  host: "trybe.com"
]

import_config "dev.secret.exs"
