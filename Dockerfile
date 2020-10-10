FROM elixir:1.10-alpine AS build

RUN mix local.rebar --force
RUN mix local.hex --force

RUN mkdir /yasd
COPY . /yasd
WORKDIR /yasd

ENV MIX_ENV=prod

RUN mix deps.get
RUN mix release --path release

# Copy elixir release into apline image in second stage
FROM alpine:3 AS app

ENV LANG=C.UTF-8

# Install openssl
RUN apk update && apk add openssl ncurses-libs

# Copy over the build artifact from the previous step and create a non root user
RUN adduser -h /yasd -D app

COPY --from=build /yasd/release /yasd
WORKDIR /yasd
RUN chown -R app: /yasd 
USER app

CMD ["/yasd/bin/yasd", "start"]
