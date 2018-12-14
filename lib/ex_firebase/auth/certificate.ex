defmodule ExFirebase.Auth.Certificate do
  @moduledoc """
  Converts Firebase service account credentials into an `ExFirebase.Auth.Certificate`
  """

  alias ExFirebase.Error

  defstruct [:project_id, :private_key, :client_email]

  @type t :: %__MODULE__{
          project_id: String.t(),
          private_key: String.t(),
          client_email: String.t()
        }

  @file_path Application.get_env(:ex_firebase, :service_account_path)
  @project_id Application.get_env(:ex_firebase, :project_id)
  @private_key Application.get_env(:ex_firebase, :private_key)
  @client_email Application.get_env(:ex_firebase, :client_email)

  @doc """
  Creates a new `ExFirebase.Auth.Certificate` from file binary or map
  """
  @spec new(binary() | map()) :: __MODULE__.t() | {:error, Error.t()}
  def new(attrs) when is_binary(attrs), do: from_binary(attrs)
  def new(attrs) when is_map(attrs), do: from_map(attrs)

  @doc """
  Creates a new `ExFirebase.Auth.Certificate` from app config
  """
  @spec new :: __MODULE__.t() | {:error, Error.t()}
  def new do
    cond do
      !!is_binary(@file_path) ->
        from_file(@file_path)

      Enum.all?([@project_id, @private_key, @client_email], &is_binary(&1)) ->
        from_map(%{
          "project_id" => @project_id,
          "private_key" => @private_key,
          "client_email" => @client_email
        })

      true ->
        {:error, %Error{reason: :invalid_certificate}}
    end
  end

  defp from_file(path) when is_binary(path) do
    case File.read(path) do
      {:error, reason} -> {:error, %Error{reason: reason}}
      {:ok, binary} -> from_binary(binary)
    end
  end

  defp from_binary(binary) do
    case Poison.decode(binary) do
      {:ok, map} -> from_map(map)
      {:error, _, _} -> {:error, %Error{reason: :invalid_certificate}}
    end
  end

  defp from_map(%{
         "project_id" => project_id,
         "private_key" => private_key,
         "client_email" => client_email
       }) do
    %__MODULE__{
      project_id: project_id,
      private_key: private_key,
      client_email: client_email
    }
  end

  defp from_map(_), do: {:error, %Error{reason: :invalid_certificate}}
end
