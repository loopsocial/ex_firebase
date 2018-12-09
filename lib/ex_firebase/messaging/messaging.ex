defmodule ExFirebase.Messaging do
  @moduledoc """
  Firebase messaging interface
  """

  alias ExFirebase.{Auth, Error}
  alias ExFirebase.Messaging.{HTTP, QueueProducer}

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
  def send(payload) when is_map(payload) do
    with {:ok, access_token} <- Auth.get_access_token() do
      @http_module.send(payload, access_token)
    end
  end

  @spec send_queued(map() | list(map())) :: :ok
  def send_queued(payload) when is_map(payload) or is_list(payload) do
    QueueProducer.add(payload)
  end

  @spec send_queued(map(), list(String.t())) :: :ok
  def send_queued(%{message: %{}} = payload, tokens) when is_list(tokens) do
    tokens
    |> Enum.map(&put_in(payload, [:message, :token], &1))
    |> QueueProducer.add()
  end

  @spec send_scheduled(map(), integer()) :: :ok
  def send_scheduled(payload, seconds) when is_map(payload) and seconds > 0 do
    # TODO
    :ok
  end
end
