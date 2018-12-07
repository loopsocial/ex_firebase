defmodule ExFirebase.Auth.JWTTest do
  use ExUnit.Case

  alias ExFirebase.Auth.{Certificate, JWT}
  alias ExFirebase.Error

  test "from_certificate/1 returns a jwt" do
    %Certificate{} = cert = Certificate.new()
    assert {:ok, _token} = JWT.from_certificate(cert)
  end

  test "from_certificate/1 returns error for invalid certificate" do
    %Certificate{} =
      cert =
      Certificate.new(%{
        "project_id" => "project_id",
        "private_key" => "private_key",
        "client_email" => "client_email"
      })

    assert {:error, %Error{reason: :invalid_certificate}} = JWT.from_certificate(cert)
  end
end
