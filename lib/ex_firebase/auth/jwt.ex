defmodule ExFirebase.Auth.JWT do
  @moduledoc """
  Converts an `ExFirebase.Auth.Certificate` into a signed JWT
  """

  alias ExFirebase.Auth.Certificate
  alias ExFirebase.Error

  @algorithm "RS256"
  @oauth_token_url "https://www.googleapis.com/oauth2/v4/token"
  @one_hour_in_seconds 60 * 60
  @scopes [
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/firebase.database",
    "https://www.googleapis.com/auth/firebase.messaging",
    "https://www.googleapis.com/auth/identitytoolkit",
    "https://www.googleapis.com/auth/userinfo.email"
  ]

  @spec from_certificate(Certificate.t()) :: {:ok, String.t()} | {:error, Error.t()}
  def from_certificate(%Certificate{
        private_key: private_key,
        client_email: client_email
      })
      when is_binary(private_key) and is_binary(client_email) do
    with %JOSE.JWK{} = jwk <- JOSE.JWK.from_pem(private_key) do
      {:ok,
       jwk
       |> JOSE.JWT.sign(%{"alg" => @algorithm, "typ" => "JWT"}, %{
         "iat" => System.system_time(:second),
         "exp" => System.system_time(:second) + @one_hour_in_seconds,
         "aud" => @oauth_token_url,
         "iss" => client_email,
         "scope" => Enum.join(@scopes, " ")
       })
       |> JOSE.JWS.compact()
       |> elem(1)}
    else
      _ -> {:error, %Error{reason: :invalid_certificate}}
    end
  end
end
