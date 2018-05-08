defmodule CintApiTest do
  use ExUnit.Case
  doctest CintApi

  test "greets the world" do
    assert CintApi.hello() == :world
  end
end
