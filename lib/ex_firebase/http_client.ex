defmodule ExFirebase.HTTPClient do
  use HTTPoison.Base

  @default_headers ["Content-Type": "application/json"]

  @callback get(url :: String.t()) ::
              {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  @callback post(url :: String.t(), body :: any(), headers :: HTTPoison.Request.headers()) ::
              {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}

  def process_request_headers(headers) do
    Keyword.merge(@default_headers, headers)
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
