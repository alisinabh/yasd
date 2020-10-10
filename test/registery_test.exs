defmodule YASD.RegistryTest do
  use ExUnit.Case

  alias YASD.Registry

  test "register a service and fetching nodes work" do
    service_name = "svc-#{Enum.random(1..99999)}"
    :ok = Registry.register(service_name, "192.168.1.1")
    :ok = Registry.register(service_name, "192.168.1.2", [])
    :ok = Registry.register(service_name, "192.168.1.1", [])

    {:ok, nodes} = Registry.list_nodes(service_name)

    assert ["192.168.1.1", "192.168.1.2"] == Enum.sort(nodes)
    assert {:ok, [service_name]} == Registry.list_services()
  end

  test "tegister a tagged service and fetch by tag works" do
    service_name = "tsvc-#{Enum.random(1..99999)}"
    :ok = Registry.register(service_name, "192.168.1.1")
    :ok = Registry.register(service_name, "192.168.1.2", ["client"])
    :ok = Registry.register(service_name, "192.168.1.1", ["server"])

    assert {:ok, ["192.168.1.2"]} == Registry.list_nodes(service_name, ["client"])
    assert {:ok, ["192.168.1.1"]} == Registry.list_nodes(service_name, ["server"])
  end
end
