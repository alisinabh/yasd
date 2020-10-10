defmodule YASD.Utils do
  @moduledoc """
  Common functions used in YASD.
  """

  import Plug.Conn

  @doc """
  Encode and send json data as response to client with valid headers.
  """
  @spec send_json(Plug.Conn.t(), map() | binary() | list(), integer()) :: Plug.Conn.t()
  def send_json(conn, data, status \\ 200)

  def send_json(conn, data, status) when is_map(data) or is_list(data) do
    send_json(conn, Jason.encode!(data), status)
  end

  def send_json(conn, bin_data, status) when is_binary(bin_data) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, bin_data)
  end
end
