defmodule ExFirebase.MessagingTest do
  use ExUnit.Case

  alias ExFirebase.Messaging

  @payload %{message: %{token: "token", notification: %{title: "title"}}}

  setup do
    Messaging.delete_queue()
  end

  test "send/1 sends a push notification" do
    assert {:ok, %HTTPoison.Response{body: %{"name" => _}, status_code: 200}} =
             Messaging.send(%{message: %{notification: %{body: "Hello World"}}})
  end

  test "queue/1 adds payload to the queue" do
    Messaging.queue(@payload)
    assert [@payload] = Messaging.get_queue()
  end

  test "get_queue/0 returns queued payloads" do
    Messaging.queue([@payload, @payload])
    assert [@payload, @payload] = Messaging.get_queue()
  end

  test "get_queue_length/0 returns queued payloads" do
    Messaging.queue(@payload)
    assert Messaging.get_queue_length() == 1
  end

  test "delete_queue/0 removes queued payloads" do
    Messaging.queue(@payload)
    assert [@payload] = Messaging.get_queue()
    Messaging.delete_queue()
    assert [] = Messaging.get_queue()
  end

  test "get_queue_stats/0 returns queue attempts, successes, and failures" do
    :gproc.send({:p, :l, :fcm_queue_monitor}, {:request, @payload})
    :gproc.send({:p, :l, :fcm_queue_monitor}, {:request, @payload})
    :gproc.send({:p, :l, :fcm_queue_monitor}, {:request, @payload})

    :gproc.send(
      {:p, :l, :fcm_queue_monitor},
      {:response, {:ok, %HTTPoison.Response{body: %{name: "/messages/0:1"}, status_code: 200}},
       @payload}
    )

    :gproc.send(
      {:p, :l, :fcm_queue_monitor},
      {:response, {:ok, %HTTPoison.Response{status_code: 400}}, @payload}
    )

    :gproc.send(
      {:p, :l, :fcm_queue_monitor},
      {:response, {:ok, %HTTPoison.Error{reason: :timeout}}, @payload}
    )

    assert %{attempts: 3, failures: 2, successes: 1} = Messaging.get_queue_stats()
  end
end
