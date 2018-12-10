defmodule ExFirebase.Auth.HTTP do
  @moduledoc """
  HTTP request interface for authentication modules
  """

  alias ExFirebase.{Auth, HTTPClient}

  @public_keys_url "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com"

  @callback get_public_keys :: {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  @callback get_access_token(String.t()) ::
              {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}

  def get_public_keys, do: HTTPClient.get(@public_keys_url)

  def get_access_token(jwt) when is_binary(jwt) do
    HTTPClient.post(
      Auth.oauth_token_url(),
      {:form,
       [
         {"grant_type", "urn:ietf:params:oauth:grant-type:jwt-bearer"},
         {"assertion", jwt}
       ]},
      [{"content-type", "application/x-www-form-urlencoded"}]
    )
  end
end
