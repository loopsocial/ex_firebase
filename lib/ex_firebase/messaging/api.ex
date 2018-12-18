defmodule ExFirebase.Messaging.API do
  @moduledoc """
  HTTP request interface for messaging modules
  """

  alias ExFirebase.{Config, HTTPClient}

  @http_client Application.get_env(:ex_firebase, :http_client) || HTTPClient

  @callback send(body :: map(), access_token :: String.t()) ::
              {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}

  @spec send(map(), String.t()) :: {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def send(payload, access_token) when is_map(payload) and is_binary(access_token) do
    @http_client.post(fcm_url(), payload, [
      {"Authorization", "Bearer #{access_token}"}
    ])
  end

  defp fcm_url do
    "https://fcm.googleapis.com/v1/projects/" <> Config.project_id() <> "/messages:send"
  end
end
