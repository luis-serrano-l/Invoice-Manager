mix deps.get
mix assets.deploy
mix compile
mix phx.digest
mix ecto.setup
mix run priv/repo/seeds.exs
mix phx.server