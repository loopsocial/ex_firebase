defmodule ExFirebase.HTTPClient do
  use HTTPoison.Base

  @default_headers [{"Content-Type", "application/json"}]

  def process_request_headers(headers) do
    Enum.into(headers, @default_headers)
  end

  def process_request_body(body) when is_map(body), do: Poison.encode!(body)
  def process_request_body(body), do: body

  def process_response_body(body) do
    case Poison.decode(body) do
      {:ok, map} -> map
      {:error, _, _} -> body
    end
  end
end
