defmodule ExFirebase.Auth.TokenVerifier do
  @moduledoc """
  Module for verifying the authenticity of Firebase ID Tokens (JWT's)
  that are generated by Firebase client SDK's.
  See: [https://firebase.google.com/docs/auth/admin/verify-id-tokens](https://firebase.google.com/docs/auth/admin/verify-id-tokens)
  """
  alias ExFirebase.Auth.PublicKeyManager
  alias ExFirebase.Error

  @allowed_algos ["RS256"]

  def verify(token) do
    with %JOSE.JWT{
           fields: %{
             "aud" => aud,
             "auth_time" => auth_time,
             "exp" => exp,
             "iat" => iat,
             "iss" => iss
           }
         } <- JOSE.JWT.peek(token),
         {:ok, _aud} <- verify_audience(aud),
         {:ok, _auth_time} <- verify_auth_time(auth_time),
         {:ok, _exp} <- verify_expiration_time(exp),
         {:ok, _iat} <- verify_issued_at_time(iat),
         {:ok, _iss} <- verify_issuer(iss),
         %JOSE.JWS{fields: %{"kid" => key_id}} <- JOSE.JWT.peek_protected(token),
         {:ok, key} <- PublicKeyManager.get_key(key_id) do
      verify_jwt_signature_with_key(token, key)
    end
  end

  defp verify_audience(aud) do
    cond do
      aud == ExFirebase.project_id() -> {:ok, aud}
      true -> {:error, %Error{reason: :invalid_aud}}
    end
  end

  defp verify_auth_time(auth_time) do
    cond do
      auth_time <= DateTime.to_unix(DateTime.utc_now()) -> {:ok, auth_time}
      true -> {:error, %Error{reason: :invalid_auth_time}}
    end
  end

  defp verify_expiration_time(exp) do
    cond do
      exp > DateTime.to_unix(DateTime.utc_now()) -> {:ok, exp}
      true -> {:error, %Error{reason: :invalid_exp}}
    end
  end

  defp verify_issued_at_time(iat) do
    cond do
      iat <= DateTime.to_unix(DateTime.utc_now()) -> {:ok, iat}
      true -> {:error, %Error{reason: :invalid_iat}}
    end
  end

  defp verify_issuer(iss) do
    cond do
      iss == "https://securetoken.google.com/#{ExFirebase.project_id()}" -> {:ok, iss}
      true -> {:error, %Error{reason: :invalid_iss}}
    end
  end

  # Validate that this JWT was signed with the private key corresponding
  # to the public key that is listed in the JWT's kid header.
  defp verify_jwt_signature_with_key(signed_jwt, public_key) do
    with %JOSE.JWK{} = jwk <- JOSE.JWK.from_pem(public_key),
         {true, %JOSE.JWT{} = jwt, %JOSE.JWS{}} <-
           JOSE.JWT.verify_strict(jwk, @allowed_algos, signed_jwt) do
      {:ok, jwt}
    else
      _ -> {:error, %Error{reason: :invalid_jwt}}
    end
  end
end
