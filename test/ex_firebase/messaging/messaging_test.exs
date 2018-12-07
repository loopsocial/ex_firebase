defmodule ExFirebase.MessagingTest do
  use ExUnit.Case

  alias ExFirebase.Messaging

  test "send/1 sends a push notification" do
    assert {:ok, %HTTPoison.Response{body: %{"name" => _}, status_code: 200}} =
             Messaging.send(%{message: %{notification: %{body: "Hello World"}}})
  end
end
