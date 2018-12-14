defmodule ExFirebase.Auth.AccessTokenManagerTest do
  use ExUnit.Case

  alias ExFirebase.Auth.AccessTokenManager

  test "get_token/0 returns token" do
    assert {:ok, _} = AccessTokenManager.get_access_token()
  end
end
