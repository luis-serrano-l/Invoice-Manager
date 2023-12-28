FROM elixir:1.14

RUN apt-get update && apt-get install -y nodejs

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force 

RUN mkdir /app

COPY . /app/

WORKDIR /app

RUN mix deps.get

RUN mix assets.deploy

RUN mix compile

RUN mix phx.digest

COPY entrypoint.sh /app/entrypoint.sh

RUN chmod +x /app/entrypoint.sh
