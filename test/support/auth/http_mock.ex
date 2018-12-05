defmodule ExFirebase.Auth.HTTPMock do
  @behaviour ExFirebase.Auth.HTTP

  @keys File.cwd!()
        |> Path.join("/test/fixtures/keys.json")
        |> File.read!()
        |> Poison.decode!()

  def fetch_keys do
    {:ok,
     %{
       body: @keys,
       headers: [{"cache-control", "public, max-age=20058, must-revalidate, no-transform"}],
       status_code: 200
     }}
  end
end
