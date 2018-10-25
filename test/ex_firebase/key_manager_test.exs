defmodule ExFirebase.KeyManagerTest do
  use ExUnit.Case

  import Mock

  alias ExFirebase.KeyManager

  @keys File.cwd!()
        |> Path.join("/test/fixtures/keys.json")
        |> File.read!()
        |> Poison.decode!()

  test "get_key/1 returns a key if it exists" do
    with_mock KeyManager, [:passthrough],
      fetch_keys: fn ->
        {:ok, @keys}
      end do
      {key_id, key} = Enum.at(@keys, 0)
      assert {:ok, ^key} = KeyManager.get_key(key_id)
    end
  end

  test "get_key/1 returns error if key does not exist" do
    with_mock KeyManager, [:passthrough],
      fetch_keys: fn ->
        {:ok, @keys}
      end do
      assert {:error, :not_found} = KeyManager.get_key("invalid")
    end
  end
end
