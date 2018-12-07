defmodule ExFirebase.Auth.Certificate do
  alias ExFirebase.Error

  defstruct [:project_id, :private_key, :client_email]

  @type t :: %__MODULE__{
          project_id: binary(),
          private_key: binary(),
          client_email: binary()
        }

  @doc """
  Reads a service account key file and returns an `%ExFirebase.Auth.Certificate{}`
  """
  @spec get_certificate :: {:ok, __MODULE__.t()} | {:error, Error.t()}
  def get_certificate, do: get_service_account_key(service_account_key_path())

  defp get_service_account_key(nil), do: {:error, %Error{reason: :enoent}}

  defp get_service_account_key(path) when is_binary(path) do
    case File.read(path) do
      {:error, reason} -> {:error, %Error{reason: reason}}
      {:ok, binary} -> decode_key(binary)
    end
  end

  defp decode_key(binary) do
    case Poison.decode(binary) do
      {:ok, key} -> parse_key(key)
      {:error, _, _} -> {:error, %Error{reason: :invalid_key}}
    end
  end

  defp parse_key(%{
         "project_id" => project_id,
         "private_key" => private_key,
         "client_email" => client_email
       }) do
    {:ok,
     %__MODULE__{
       project_id: project_id,
       private_key: private_key,
       client_email: client_email
     }}
  end

  defp parse_key(_), do: {:error, %Error{reason: :invalid_key}}

  defp service_account_key_path do
    Application.get_env(:ex_firebase, :service_account_key_path)
  end
end
