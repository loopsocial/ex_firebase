defmodule ExFirebase.HTTPClient do
  alias ExFirebase.{HTTPError, HTTPResponse}

  @type body :: map() | binary()
  @type headers :: [{binary(), binary()}]

  @default_headers [{"content-type", "application/json"}]

  @spec get(url :: binary(), headers :: headers, options :: Keyword.t()) :: HTTPResponse.t()
  def get(url, headers \\ @default_headers, options \\ []) do
    url
    |> HTTPoison.get(headers, options)
    |> parse_response()
  end

  @spec post(
          url :: binary(),
          body :: body,
          headers :: headers,
          options :: Keyword.t()
        ) :: HTTPResponse.t()
  def post(url, body, headers \\ @default_headers, options \\ []) do
    url
    |> HTTPoison.post(encode_body(body, headers), headers, options)
    |> parse_response()
  end

  defp parse_response(
         {:ok, %HTTPoison.Response{body: body, headers: headers, status_code: status_code}}
       ) do
    cond do
      status_code < 400 ->
        {:ok,
         %HTTPResponse{
           body: decode_body(body),
           headers: headers,
           status_code: status_code
         }}

      true ->
        {:error,
         %HTTPResponse{
           body: decode_body(body),
           headers: headers,
           status_code: status_code
         }}
    end
  end

  defp parse_response({:error, %HTTPoison.Error{reason: reason}}) do
    {:error, %HTTPError{reason: reason}}
  end

  defp encode_body(body, headers) when is_map(body) do
    case Enum.find(headers, fn {k, _v} -> k == "content-type" end) do
      {_, "application-json"} ->
        Poison.encode!(body)

      {_, "application/x-www-form-urlencoded"} ->
        body
        |> Enum.map(fn {k, v} -> "#{k}=#{v}" end)
        |> Enum.join("&")

      _ ->
        body
    end
  end

  defp encode_body(body, _headers), do: body

  defp decode_body(body) do
    case Poison.decode(body) do
      {:ok, map} -> map
      {:error, _, _} -> body
    end
  end
end
