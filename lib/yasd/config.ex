defmodule YASD.Config do
  @moduledoc """
  Configuration helpers for YASD.

  ## Environment variables
  - `JANITOR_SWEEP_INTERVAL`: Amount of time to run janitor on services in seconds. (default: 30)
  - `HEARTBEAT_TIMEOUT`: Amount of time which a node is considered dead afterwards in seconds. (default: 90)
  """

  def load do
    Application.put_env(
      :yasd,
      :janitor_sweep_interval,
      System.get_env("JANITOR_SWEEP_INTERVAL") || 30
    )

    Application.put_env(
      :yasd,
      :heartbeat_timeout,
      System.get_env("HEARTBEAT_TIMEOUT") || 90
    )
  end

  def get_janitor_sweep_interval, do: Application.get_env(:yasd, :janitor_sweep_interval)
  def get_heartbeat_timeout, do: Application.get_env(:yasd, :heartbeat_timeout)
end
