defmodule ExFirebase.Auth do
  @moduledoc """
  Firebase authentication interface
  """
  alias ExFirebase.Auth.TokenVerifier

  @doc """
  Verifies token claims and signature, and converts binary token into a `%JOSE.JWT{}`

  ## Parameters

    token - Signed JSON Web Token

  ## Examples

      iex> ExFirebase.Auth.verify_token("eyJhbGciOiJS...")
      {:ok,
       %JOSE.JWT{
         fields: %{
           "aud" => "example-project-id",
           "auth_time" => 1540314428,
           "exp" => 1540318028,
           "firebase" => %{
             "identities" => %{"phone" => ["+10000000001"]},
             "sign_in_provider" => "phone"
           },
           "iat" => 1540314428,
           "iss" => "https://securetoken.google.com/example-project-id",
           "phone_number" => "+10000000001",
           "sub" => "O5dHhHaWzsgUdNo6jIeTrWykPVd2",
           "user_id" => "O5dHhHaWzsgUdNo6jIeTrWykPVd2"
         }
       }}
  """
  defdelegate verify_token(token), to: TokenVerifier, as: :verify_token
end
