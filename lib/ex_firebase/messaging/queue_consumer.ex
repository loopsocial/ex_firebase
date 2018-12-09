defmodule ExFirebase.Messaging.QueueConsumer do
  alias ExFirebase.{Error, Messaging}

  require Logger

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
    IO.inspect("sent #{inspect(payload)}")
    Process.sleep(1000)
  end

  defp send_message(payload) do
    Logger.info("""
    #{__MODULE__} Sending FCM Push Notification
    #{inspect(payload)}
    """)

    payload
    |> Messaging.send()
    |> parse_response(payload)
    |> handle_result()
  end

  defp parse_response(
         {:ok, %HTTPoison.Response{body: %{"name" => name}, status_code: 200}},
         _payload
       ) do
    {:ok, name}
  end

  defp parse_response(
         {:ok,
          %HTTPoison.Response{
            body: %{
              "error" => %{
                "status" => "UNAVAILABLE"
              }
            }
          }},
         payload
       ) do
    {:retry, payload}
  end

  defp parse_response({:ok, %HTTPoison.Response{body: body}}, payload) do
    {:error, body, payload}
  end

  defp parse_response({:error, %HTTPoison.Error{reason: reason}}, payload) do
    {:error, reason, payload}
  end

  defp parse_response({:error, %Error{reason: reason}}, payload) do
    {:error, reason, payload}
  end

  defp handle_result({:ok, name}) do
    IO.inspect({:ok, name})
  end

  defp handle_result({:retry, payload}) do
    Messaging.schedule(payload, @retry_offset_seconds)
  end

  defp handle_result({:error, response, payload}) do
    Logger.info("""
    #{__MODULE__} FCM Error
    request: #{inspect(payload)}
    response: #{inspect(response)}
    """)
  end
end
