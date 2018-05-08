# CintApi

A simple wrapper for CINT.com REST API.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `cint_api` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:cint_api, "~> 0.1.0"}
  ]
end
```

### Config

Copy your push service credentials to application config file:

```
config :cint_api, CintApi,
  url: "https://cdp.cintworks.net/"
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/cint_api](https://hexdocs.pm/cint_api).
