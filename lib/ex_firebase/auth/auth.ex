defmodule ExFirebase.Auth do
  @moduledoc """
  Firebase authentication interface
  """
  alias ExFirebase.{Error}

  alias ExFirebase.Auth.{
    AccessTokenManager,
    Certificate,
    JWT,
    TokenVerifier
  }

  @http_module Application.get_env(:ex_firebase, :auth_http_module) || ExFirebase.Auth.HTTP

  @oauth_token_url "https://www.googleapis.com/oauth2/v4/token"
  def oauth_token_url, do: @oauth_token_url

  @doc """
  Returns a cached access token

  ## Examples

      iex> ExFirebase.Auth.get_access_token()
      {:ok, "1/8xbJqaOZXSUZbHLl5EOtu1pxz3fmmetKx9W8CV4t79M"}
  """
  @spec get_access_token :: {:ok, binary()} | {:error, Error.t()}
  defdelegate get_access_token, to: AccessTokenManager, as: :get_token

  @doc """
  Makes an HTTP request for an OAuth2 access token using a service account's credentials

  ## Examples

      iex(14)> ExFirebase.Auth.get_new_access_token()
      {:ok,
       %HTTPoison.Response{
         body: %{
           "access_token" => "1/8xbJqaOZXSUZbHLl5EOtu1pxz3fmmetKx9W8CV4t79M",
           "expires_in" => 3600,
           "token_type" => "Bearer"
         },
         ...
         status_code: 200
       }}
  """
  @spec get_new_access_token ::
          {:ok, HTTPoison.Response.t()}
          | {:error, HTTPoison.Error.t()}
          | {:error, Error.t()}
  def get_new_access_token do
    with %Certificate{} = certificate <- Certificate.new(),
         {:ok, jwt} <- JWT.from_certificate(certificate) do
      @http_module.get_access_token(jwt)
    end
  end

  @doc """
  Verifies the claims and signature of a Firebase Auth ID token

  ## Examples

      iex> ExFirebase.Auth.verify_token("eyJhbGciOiJS...")
      {:ok,
       %JOSE.JWT{
         fields: %{
           "aud" => "myproject-id",
           "auth_time" => 1540314428,
           "exp" => 1540318028,
           "firebase" => %{
             "identities" => %{"phone" => ["+16505553434"]},
             "sign_in_provider" => "phone"
           },
           "iat" => 1540314428,
           "iss" => "https://securetoken.google.com/myproject-id",
           "phone_number" => "+16505553434",
           "sub" => "O5dHhHaWzsgUdNo6jIeTrWykPVd2",
           "user_id" => "O5dHhHaWzsgUdNo6jIeTrWykPVd2"
         }
       }}
  """
  @spec verify_token(binary()) :: {:ok, JOSE.JWT.t()} | {:error, Error.t()}
  defdelegate verify_token(token), to: TokenVerifier, as: :verify

  @doc """
  Makes an HTTP request to get Google's public keys, whose private keys
  are used to sign Firebase Auth ID tokens
  """
  @spec get_public_keys :: {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  defdelegate get_public_keys, to: @http_module, as: :get_public_keys
end
