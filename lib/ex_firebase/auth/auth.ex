defmodule ExFirebase.Auth do
  @moduledoc """
  Firebase authentication interface
  """
  alias ExFirebase.{
    Error,
    HTTPError,
    HTTPResponse
  }

  alias ExFirebase.Auth.{
    AccessTokenManager,
    Certificate,
    Credential,
    TokenVerifier
  }

  @auth_http_client Application.get_env(:ex_firebase, :auth_http_client)

  @oauth_token_url "https://www.googleapis.com/oauth2/v4/token"
  def oauth_token_url, do: @oauth_token_url

  @doc """
  Returns a cached access token
  """
  @spec get_access_token :: {:ok, binary()} | {:error, Error.t()}
  defdelegate get_access_token, to: AccessTokenManager, as: :get_token

  @doc """
  Makes an HTTP request for an OAuth2 access token using a service account's credentials
  """
  @spec get_new_access_token ::
          {:ok, HTTPResponse.t()}
          | {:error, HTTPResponse.t()}
          | {:error, HTTPError.t()}
          | {:error, Error.t()}
  def get_new_access_token do
    with {:ok, %Certificate{} = certificate} <- Certificate.get_certificate(),
         {:ok, jwt} <- Credential.create_jwt_from_certificate(certificate) do
      @auth_http_client.get_access_token(jwt)
    end
  end

  @doc """
  Verifies the claims and signature of a Firebase Auth ID token,
  and converts binary token into a `JOSE.JWT`
  """
  @spec verify_token(token :: binary()) :: {:ok, JOSE.JWT.t()} | {:error, Error.t()}
  defdelegate verify_token(token), to: TokenVerifier, as: :verify

  @doc """
  Makes an HTTP request to get Google's public keys, whose private keys
  are used to sign Firebase Auth ID tokens
  """
  @spec get_public_keys ::
          {:ok, HTTPResponse.t()}
          | {:error, HTTPResponse.t()}
          | {:error, HTTPError.t()}
  defdelegate get_public_keys, to: @auth_http_client, as: :get_public_keys
end
