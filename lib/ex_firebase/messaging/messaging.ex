defmodule ExFirebase.Messaging do
  @moduledoc """
  Firebase messaging interface
  """

  alias ExFirebase.{Auth, Error}
  alias ExFirebase.Messaging.{HTTP, QueueMonitor, QueueProducer, Scheduler}

  @http_module Application.get_env(:ex_firebase, :messaging_http_module) || HTTP

  @doc """
  Sends a push notification with Firebase Cloud Messaging v1 API

  ## Examples

      iex> ExFirebase.Messaging.send(%{message: %{token: "dyZHH...", notification: %{body: "Hello World"}}})
      {:ok,
       %HTTPoison.Response{
         body: %{
           "name" => "projects/project-id/messages/0:1544204830625699%2575e27c2575e27c"
         },
         ...
         status_code: 200
       }}

      iex> ExFirebase.Messaging.send(%{message: %{token: ""}})
      {:ok,
       %HTTPoison.Response{
         body: %{
           "error" => %{
             "code" => 400,
             "details" => [...],
             "message" => "The registration token is not a valid FCM registration token",
             "status" => "INVALID_ARGUMENT"
           }
         },
         ...
         status_code: 400
       }}
  """
  @spec send(map()) ::
          {:ok, HTTPoison.Response.t()}
          | {:error, HTTPoison.Error.t()}
          | {:error, Error.t()}
  def send(payload) do
    with {:ok, access_token} <- Auth.get_access_token() do
      @http_module.send(payload, access_token)
    end
  end

  @spec queue(map() | list(map())) :: :ok
  def queue(payload) do
    QueueProducer.add(payload)
  end

  @spec queue(map(), list(String.t())) :: :ok
  def queue(payload, tokens) do
    payload
    |> put_tokens(tokens)
    |> QueueProducer.add()
  end

  @spec schedule(map() | list(map()), integer()) :: :ok
  def schedule(payload, seconds) do
    Scheduler.schedule(payload, seconds)
  end

  @spec schedule(map(), list(String.t()), integer()) :: :ok
  def schedule(payload, tokens, seconds) do
    payload
    |> put_tokens(tokens)
    |> Scheduler.schedule(seconds)
  end

  defp put_tokens(payload, tokens) do
    Enum.map(tokens, &put_in(payload, [:message, :token], &1))
  end

  @spec get_queue :: list(map())
  defdelegate get_queue, to: QueueProducer, as: :get_queue

  @spec get_queue_length :: integer()
  defdelegate get_queue_length, to: QueueProducer, as: :get_length

  @spec get_queue_stats :: QueueMonitor.state()
  defdelegate get_queue_stats, to: QueueMonitor, as: :get_stats
end
