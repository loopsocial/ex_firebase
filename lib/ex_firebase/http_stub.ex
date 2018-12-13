defmodule ExFirebase.HTTPStub do
  @behaviour ExFirebase.HTTPClient

  def get(_url), do: {:error, %HTTPoison.Error{reason: :stubbed}}

  def post(_url, _body, _headers), do: {:error, %HTTPoison.Error{reason: :stubbed}}
end
