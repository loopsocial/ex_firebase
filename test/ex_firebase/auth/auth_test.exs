defmodule ExFirebase.AuthTest do
  use ExUnit.Case

  alias ExFirebase.{Auth, Error}

  @public_keys File.cwd!()
               |> Path.join("/test/fixtures/public-keys.json")
               |> File.read!()
               |> Poison.decode!()

  test "access_token/0 returns cached access token" do
    assert {:ok, _access_token} = Auth.access_token()
  end

  test "get_access_token/0 fetches new access token" do
    assert {:ok, %HTTPoison.Response{body: %{"access_token" => _}, status_code: 200}} =
             Auth.get_access_token()
  end

  test "public_keys/0 returns cached public keys" do
    assert @public_keys = Auth.public_keys()
  end

  test "get_public_keys/0 fetches new public keys" do
    assert {:ok, %HTTPoison.Response{body: @public_keys}} = Auth.get_public_keys()
  end

  test "get_public_key/1 returns a key if it exists" do
    {key_id, key} = Enum.at(@public_keys, 0)
    assert {:ok, ^key} = Auth.get_public_key(key_id)
  end

  test "get_public_key/1 returns error if key does not exist" do
    assert {:error, %Error{reason: :not_found}} = Auth.get_public_key("invalid")
  end
end
