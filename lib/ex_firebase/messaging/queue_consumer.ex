defmodule ExFirebase.Messaging.QueueConsumer do
  @moduledoc """
  The final consumer in the Queue GenStage pipeline.
  It sends FCM requests and casts results to :queue_monitor.
  """

  alias ExFirebase.{Error, Messaging}
  alias ExFirebase.Messaging.QueueMonitor

  @queue_monitor Application.get_env(:ex_firebase, :queue_monitor) || QueueMonitor
  @retry_offset_seconds 60

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
    @queue_monitor.fcm_request(payload)

    payload
    |> Messaging.send()
    |> parse_response(payload)
    |> handle_result()
  end

  defp parse_response(
         {:ok, %HTTPoison.Response{body: body, status_code: 200}},
         payload
       ) do
    {:ok, body, payload}
  end

  defp parse_response(
         {:ok,
          %HTTPoison.Response{
            body:
              %{
                "error" => %{
                  "status" => "UNAVAILABLE"
                }
              } = body
          }},
         payload
       ) do
    {:retry, body, payload}
  end

  defp parse_response({:ok, %HTTPoison.Response{} = error}, payload) do
    {:error, error, payload}
  end

  defp parse_response({:error, %HTTPoison.Error{} = error}, payload) do
    {:error, error, payload}
  end

  defp parse_response({:error, %Error{} = error}, payload) do
    {:error, error, payload}
  end

  defp handle_result({:ok, body, payload}) do
    @queue_monitor.fcm_response({:ok, body, payload})
  end

  defp handle_result({:retry, body, payload}) do
    @queue_monitor.fcm_response({:retry, body, payload})
    Messaging.schedule(payload, @retry_offset_seconds)
  end

  defp handle_result({:error, error, payload}) do
    @queue_monitor.fcm_response({:error, error, payload})
  end
end
