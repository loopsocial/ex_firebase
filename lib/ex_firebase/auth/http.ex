defmodule ExFirebase.Auth.HTTP do
  @moduledoc """
  HTTP request interface for authentication modules
  """
  alias ExFirebase.Auth
  alias ExFirebase.HTTPClient

  @callback get_public_keys :: {:ok, map()} | {:error, any()}
  @callback get_access_token(jwt :: binary()) :: {:ok, map()} | {:error, any()}

  @public_keys_url "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com"
  def get_public_keys, do: HTTPClient.get(@public_keys_url)

  def get_access_token(jwt) when is_binary(jwt) do
    HTTPClient.post(
      Auth.oauth_token_url(),
      %{
        grant_type: URI.encode_www_form("urn:ietf:params:oauth:grant-type:jwt-bearer"),
        assertion: jwt
      },
      [{"content-type", "application/x-www-form-urlencoded"}]
    )
  end
end
