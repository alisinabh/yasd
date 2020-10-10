defmodule YASD.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    port = String.to_integer(System.get_env("PORT") || "4001")

    children = [
      # Starts a worker by calling: YASD.Worker.start_link(arg)
      # {YASD.Worker, arg}
      {Plug.Cowboy, scheme: :http, plug: YASD.Router, options: [port: port]},
      YASD.Registry
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: YASD.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
