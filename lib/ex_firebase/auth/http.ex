defmodule ExFirebase.Auth.HTTP do
  @moduledoc """
  HTTP request interface for authentication modules
  """
  alias ExFirebase.HTTPClient

  @callback fetch_keys :: {:ok, map()} | {:error, any()}

  @key_url "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com"

  def fetch_keys, do: HTTPClient.get(@key_url)
end
