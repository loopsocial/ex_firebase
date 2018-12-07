defmodule ExFirebase.Auth.PublicKeyManager do
  @moduledoc """
  GenServer process for storing Firebase public keys.
  The process fetches keys upon startup and reloads them when cache expires.
  """
  use GenServer

  alias ExFirebase.Auth
  alias ExFirebase.{Error, HTTPError, HTTPResponse}

  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @doc """
  Retrieves a key stored in state by id
  """
  @spec get_key(key_id :: binary()) :: {:ok, binary()} | {:error, Error.t()}
  def get_key(key_id) do
    case GenServer.call(__MODULE__, {:get_key, key_id}) do
      nil -> {:error, %Error{reason: :not_found}}
      key -> {:ok, key}
    end
  end

  @doc """
  Returns all keys stored in state
  """
  @spec get_keys :: %{binary() => binary()} | %{}
  def get_keys do
    GenServer.call(__MODULE__, :get_keys)
  end

  @doc """
  Makes a request to fetch keys and store them in state.
  """
  def update_keys do
    GenServer.cast(__MODULE__, :update_keys)
  end

  @impl GenServer
  def init(_) do
    {:ok, %{}, {:continue, :init}}
  end

  @impl GenServer
  def handle_continue(:init, state) do
    update_keys()
    {:noreply, state}
  end

  @impl GenServer
  def handle_call({:get_key, key_id}, _from, state) do
    {:reply, state[key_id], state}
  end

  @impl GenServer
  def handle_call(:get_keys, _from, state) do
    {:reply, state, state}
  end

  @impl GenServer
  def handle_cast(:update_keys, state) do
    case Auth.get_public_keys() do
      {:ok, %HTTPResponse{body: keys, headers: headers}} ->
        reload_after_cache_expiration(headers)
        {:noreply, keys}

      {:error, error} ->
        if retry_for_error?(error) do
          Logger.debug("[#{__MODULE__}] error fetching keys #{inspect(error)}, retrying...")
          set_reload_timer(10)
        else
          Logger.debug("[#{__MODULE__}] error fetching keys #{inspect(error)}, aborting.")
        end

        {:noreply, state}
    end
  end

  defp retry_for_error?(%HTTPError{}), do: true
  defp retry_for_error?(%HTTPResponse{}), do: true
  defp retry_for_error?(_), do: false

  @impl GenServer
  def handle_info(:reload_keys, state) do
    update_keys()
    {:noreply, state}
  end

  defp reload_after_cache_expiration(headers) do
    headers
    |> Enum.find(fn {k, _v} -> String.downcase(k) == "cache-control" end)
    |> elem(1)
    |> String.split(", ")
    |> Enum.find(&String.match?(&1, ~r/max-age=.*/))
    |> String.split("=")
    |> Enum.at(1)
    |> String.to_integer()
    |> set_reload_timer()
  end

  defp set_reload_timer(seconds) do
    Process.send_after(__MODULE__, :reload_keys, :timer.seconds(seconds))
  end
end
