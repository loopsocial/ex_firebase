defmodule ExFirebase.KeyManager do
  @moduledoc """
  GenServer process for retrieving and storing Firebase public keys.
  The process fetches keys upon startup and reloads them when cache expires.
  """
  use GenServer

  require Logger

  @key_url "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com"

  # Client

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @doc """
  Public API for retrieving a key.

  ## Parameters

    key_id - ID of the Firebase public key

  ## Examples

      iex> ExFirebase.KeyManager.get_key("7a1eb516ae416857b3f074ed41892e643c00f2e5")
      {:ok,
       "-----BEGIN CERTIFICATE-----M3ZOdlMa...8s=-----END CERTIFICATE-----"}
  """
  def get_key(key_id) do
    case GenServer.call(__MODULE__, {:get_key, key_id}) do
      nil -> {:error, :not_found}
      key -> {:ok, key}
    end
  end

  @doc """
  Makes a request to fetch keys and store them in state.
  """
  def update_keys do
    GenServer.cast(__MODULE__, :update_keys)
  end

  # Server

  @impl GenServer
  def init(_) do
    {:ok, %{}, {:continue, :init}}
  end

  @impl GenServer
  def handle_continue(:init, state) do
    # Makes the first request to fetch the keys and store
    # them in state after the GenServer is started.
    update_keys()
    {:noreply, state}
  end

  @impl GenServer
  def handle_call({:get_key, key_id}, _from, state) do
    {:reply, state[key_id], state}
  end

  @impl GenServer
  def handle_cast(:update_keys, state) do
    case fetch_keys() do
      {:ok, keys} -> {:noreply, keys}
      {:error, _} -> {:noreply, state}
    end
  end

  @impl GenServer
  def handle_info(:reload_keys, state) do
    update_keys()
    {:noreply, state}
  end

  def fetch_keys do
    case HTTPoison.get(@key_url) do
      {:ok, %HTTPoison.Response{body: body, headers: headers, status_code: 200}} ->
        # Reload the keys after the cache-control header has expired
        set_reload_from_headers(headers)
        {:ok, Poison.decode!(body)}

      {:error, error} ->
        Logger.warn("Error getting Firebase keys #{inspect(error)}")
        # Retry in 10 seconds if we could not fetch the keys
        set_reload(10)
        {:error, error}
    end
  end

  defp set_reload_from_headers(headers) do
    headers
    |> Enum.find(fn {k, _v} -> String.downcase(k) == "cache-control" end)
    |> elem(1)
    |> String.split(", ")
    |> Enum.find(&String.match?(&1, ~r/max-age=.*/))
    |> String.split("=")
    |> Enum.at(1)
    |> String.to_integer()
    |> set_reload()
  end

  defp set_reload(seconds) do
    Process.send_after(__MODULE__, :reload_keys, :timer.seconds(seconds))
  end
end
