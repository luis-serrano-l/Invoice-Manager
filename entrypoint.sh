mix deps.get
mix assets.deploy
mix compile
mix phx.digest
mix ecto.setup
mix phx.server