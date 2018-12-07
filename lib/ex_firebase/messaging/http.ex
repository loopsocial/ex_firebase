defmodule ExFirebase.Messaging.HTTP do
  @moduledoc """
  HTTP request interface for messaging modules
  """
  alias ExFirebase.HTTPClient

  @callback send(body :: map(), access_token :: binary()) ::
              {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}

  @fcm_path "https://fcm.googleapis.com/v1/projects/"
  @messaging_path "/messages:send"

  @spec send(map(), binary()) :: {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def send(body, access_token) when is_map(body) and is_binary(access_token) do
    HTTPClient.post(fcm_url(), body, [
      {"Authorization", "Bearer #{access_token}"}
    ])
  end

  defp fcm_url do
    @fcm_path <> ExFirebase.project_id() <> @messaging_path
  end
end
