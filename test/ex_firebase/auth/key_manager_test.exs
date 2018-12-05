defmodule ExFirebase.Auth.KeyManagerTest do
  use ExUnit.Case

  alias ExFirebase.Auth.KeyManager

  @keys File.cwd!()
        |> Path.join("/test/fixtures/keys.json")
        |> File.read!()
        |> Poison.decode!()

  test "is started in application supervision tree" do
    {:error, {{:already_started, _}, _}} = start_supervised(KeyManager)
  end

  test "get_key/1 returns a key if it exists" do
    {key_id, key} = Enum.at(@keys, 0)
    assert {:ok, ^key} = KeyManager.get_key(key_id)
  end

  test "get_key/1 returns error if key does not exist" do
    assert {:error, :not_found} = KeyManager.get_key("invalid")
  end
end
