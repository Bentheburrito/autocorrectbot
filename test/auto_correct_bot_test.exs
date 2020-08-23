defmodule AutoCorrectBotTest do
  use ExUnit.Case
  doctest AutoCorrectBot

  test "greets the world" do
    assert AutoCorrectBot.hello() == :world
  end
end
