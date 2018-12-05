defmodule ExFirebase.HTTPClient do
  def get(url, headers \\ [], options \\ []) do
    url
    |> HTTPoison.get(headers, options)
    |> parse_response()
  end

  defp parse_response({:ok, %{body: body, headers: headers, status_code: status_code}}) do
    {:ok, %{body: Poison.decode!(body), headers: headers, status_code: status_code}}
  end

  defp parse_response({:error, error}), do: {:error, error}
end
