FROM elixir:1.14

RUN apt-get update && apt-get install -y nodejs

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force 

WORKDIR /app

RUN find . -type d -exec chmod 755 {} \;
RUN find . -type f -exec chmod 644 {} \;

EXPOSE 4000