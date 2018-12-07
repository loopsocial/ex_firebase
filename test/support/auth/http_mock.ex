defmodule ExFirebase.Auth.HTTPMock do
  alias ExFirebase.HTTPResponse

  @behaviour ExFirebase.Auth.HTTP

  @public_keys File.cwd!()
               |> Path.join("/test/fixtures/public_keys.json")
               |> File.read!()
               |> Poison.decode!()

  def get_public_keys do
    {:ok,
     %HTTPResponse{
       body: @public_keys,
       headers: [{"cache-control", "public, max-age=20058, must-revalidate, no-transform"}],
       status_code: 200
     }}
  end

  def get_access_token(_) do
    {:ok,
     %HTTPResponse{
       body: %{
         "access_token" => "1/8xbJqaOZXSUZbHLl5EOtu1pxz3fmmetKx9W8CV4t79M",
         "expires_in" => 3600,
         "token_type" => "Bearer"
       },
       headers: [],
       status_code: 200
     }}
  end
end
