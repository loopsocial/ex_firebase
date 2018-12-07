defmodule ExFirebase.AuthTest do
  use ExUnit.Case

  alias ExFirebase.Auth

  @public_keys File.cwd!()
               |> Path.join("/test/fixtures/public-keys.json")
               |> File.read!()
               |> Poison.decode!()

  test "get_access_token/0 returns token" do
    assert {:ok, _} = Auth.get_access_token()
  end

  test "get_new_access_token/1 sends a push notification" do
    assert {:ok, %HTTPoison.Response{body: %{"access_token" => _}, status_code: 200}} =
             Auth.get_new_access_token()
  end

  test "get_public_keys/0 returns keys" do
    assert {:ok, %HTTPoison.Response{body: @public_keys}} = Auth.get_public_keys()
  end
end
