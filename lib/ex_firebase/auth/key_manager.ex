defmodule ExFirebase.Auth.KeyManager do
  @moduledoc """
  GenServer process for retrieving and storing Firebase public keys.
  The process fetches keys upon startup and reloads them when cache expires.
  """
  use GenServer

  @auth_http_client Application.get_env(:ex_firebase, :auth_http_client)

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @doc """
  Public API for retrieving a key.

  ## Parameters

    key_id - ID of the Firebase public key

  ## Examples

      iex> ExFirebase.Auth.KeyManager.get_key("7a1eb516ae416857b3f074ed41892e643c00f2e5")
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
    case @auth_http_client.fetch_keys() do
      {:ok, %{body: body, headers: headers}} ->
        # Reload the keys after the cache-control header has expired
        set_reload_from_cache_control(headers)
        {:ok, body}

      {:error, error} ->
        # Retry in 10 seconds if request failed
        set_reload(10)
        {:error, error}
    end
  end

  defp set_reload_from_cache_control(headers) do
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
