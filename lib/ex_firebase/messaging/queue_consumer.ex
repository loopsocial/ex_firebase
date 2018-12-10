defmodule ExFirebase.Messaging.QueueConsumer do
  @moduledoc """
  The final consumer in the Queue GenStage pipeline.
  It sends FCM requests and casts results to QueueMonitor.
  """

  alias ExFirebase.Messaging
  alias ExFirebase.Messaging.QueueMonitor

  def start_link(payload) do
    Task.start_link(fn ->
      send_message(payload)
    end)
  end

  def child_spec(_args) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      restart: :temporary
    }
  end

  defp send_message(payload) do
    QueueMonitor.fcm_request(payload)

    payload
    |> Messaging.send()
    |> QueueMonitor.fcm_response(payload)
  end
end
