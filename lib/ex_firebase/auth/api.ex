defmodule ExFirebase.Auth.API do
  @moduledoc """
  HTTP request interface for authentication modules
  """

  alias ExFirebase.HTTPClient

  @http_client Application.get_env(:ex_firebase, :http_client) || HTTPClient
  @oauth_token_url "https://www.googleapis.com/oauth2/v4/token"
  @public_keys_url "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com"

  @callback get_public_keys :: {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  @callback get_access_token(String.t()) ::
              {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}

  def get_public_keys, do: @http_client.get(@public_keys_url)

  def get_access_token(jwt) when is_binary(jwt) do
    @http_client.post(
      @oauth_token_url,
      {:form,
       [
         {"grant_type", "urn:ietf:params:oauth:grant-type:jwt-bearer"},
         {"assertion", jwt}
       ]},
      "Content-Type": "application/x-www-form-urlencoded"
    )
  end
end
