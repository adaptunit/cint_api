config :cint_api, CintApi,
  url: "https://api.cint.com/"

config :cint_api, email: [
  host: "trybe.com"
]

import_config "prod.secret.exs"
