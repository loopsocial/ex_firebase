defmodule ExFirebase.Auth.CertificateTest do
  use ExUnit.Case

  alias ExFirebase.Auth.Certificate

  @service_account_file File.cwd!()
                        |> Path.join("/test/fixtures/service-account.json")
                        |> File.read!()

  @project_id @service_account_file
              |> Poison.decode!()
              |> Map.get("project_id")

  test "new/0 returns a certificate from file defined in configuration" do
    assert %Certificate{project_id: @project_id} = Certificate.new()
  end

  test "new/1 returns a certificate from file content" do
    assert %Certificate{project_id: @project_id} = Certificate.new(@service_account_file)
  end

  test "new/1 returns a certificate from map attributes" do
    assert %Certificate{project_id: @project_id} =
             @service_account_file
             |> Poison.decode!()
             |> Certificate.new()
  end
end
