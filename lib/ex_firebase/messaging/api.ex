defmodule ExFirebase.Messaging.API do
  @moduledoc """
  HTTP request interface for messaging modules
  """

  alias ExFirebase.HTTPClient

  @http_client Application.get_env(:ex_firebase, :http_client) || HTTPClient
  @project_id Application.get_env(:ex_firebase, :project_id)
  @fcm_url "https://fcm.googleapis.com/v1/projects/" <> @project_id <> "/messages:send"

  @callback send(body :: map(), access_token :: String.t()) ::
              {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}

  @spec send(map(), String.t()) :: {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def send(payload, access_token) when is_map(payload) and is_binary(access_token) do
    @http_client.post(@fcm_url, payload, [
      {"Authorization", "Bearer #{access_token}"}
    ])
  end
end
