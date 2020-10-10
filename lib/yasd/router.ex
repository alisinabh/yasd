defmodule YASD.Router do
  @moduledoc """
  Plug router module for YASD API.
  """

  use Plug.Router
  use Plug.ErrorHandler

  if Mix.env() == :dev do
    use Plug.Debugger
  end

  alias YASD.{Registry, Utils}

  plug(Plug.RequestId)
  plug(Plug.Logger)

  plug(:match)
  plug(:dispatch)

  get "/healthz" do
    Utils.send_json(conn, %{"healthy" => true})
  end

  get "/api/v1/services" do
    with {:ok, services} <- Registry.list_services() do
      Utils.send_json(conn, services)
    else
      {:error, error} ->
        Utils.send_json(conn, %{"error" => error}, 400)
    end
  end

  get "/api/v1/service/:service_name/nodes" do
    conn = fetch_query_params(conn)
    service = conn.params["service_name"]

    with {:ok, nodes} <- Registry.list_nodes(service, conn.params["tags"] || []) do
      Utils.send_json(conn, nodes)
    else
      {:error, error} ->
        Utils.send_json(conn, %{"error" => error}, 400)
    end
  end

  put "/api/v1/service/:service_name/register" do
    conn = fetch_query_params(conn)
    service_name = conn.params["service_name"]
    ip = conn.params["ip"]
    tags = conn.params["tags"] || []

    with :ok <- Registry.register(service_name, ip, tags) do
      send_resp(conn, 204, "")
    else
      {:error, error} ->
        Utils.send_json(conn, %{"error" => error}, 400)
    end
  end

  match _ do
    Utils.send_json(conn, %{"error" => "not_found"}, 404)
  end
end
