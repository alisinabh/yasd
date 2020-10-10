defmodule YASDTest do
  use ExUnit.Case
  doctest YASD

  test "greets the world" do
    assert YASD.hello() == :world
  end
end
