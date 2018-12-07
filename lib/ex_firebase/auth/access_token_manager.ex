defmodule ExFirebase.Auth.AccessTokenManager do
  @moduledoc """
  GenServer process for storing a Firebase OAuth2 access token.
  The process fetches a token upon startup and reloads it upon expiration.
  """
  use GenServer

  alias ExFirebase.{Auth, Error}

  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @spec get_token :: {:ok, binary()} | {:error, Error.t()}
  def get_token do
    case GenServer.call(__MODULE__, :get_token) do
      nil -> {:error, %Error{reason: :no_token}}
      access_token -> {:ok, access_token}
    end
  end

  def update_token do
    GenServer.cast(__MODULE__, :update_token)
  end

  @impl GenServer
  def init(_) do
    {:ok, %{}, {:continue, :init}}
  end

  @impl GenServer
  def handle_continue(:init, state) do
    update_token()
    {:noreply, state}
  end

  @impl GenServer
  def handle_call(:get_token, _from, state) do
    {:reply, state[:access_token], state}
  end

  @impl GenServer
  def handle_cast(:update_token, state) do
    case Auth.get_new_access_token() do
      {:ok, %{body: %{"access_token" => access_token, "expires_in" => expires_in}}} ->
        set_reload_timer(expires_in)
        {:noreply, %{access_token: access_token}}

      error ->
        handle_request_error(error)
        {:noreply, state}
    end
  end

  defp handle_request_error({:ok, %HTTPoison.Response{} = error}) do
    retry_request_for_error(error)
  end

  defp handle_request_error({:error, %HTTPoison.Error{} = error}) do
    retry_request_for_error(error)
  end

  defp handle_request_error(error) do
    Logger.debug("[#{__MODULE__}] #{inspect(error)}, aborting.")
  end

  defp retry_request_for_error(error) do
    Logger.debug("[#{__MODULE__}] #{inspect(error)}, retrying...")
    set_reload_timer(10)
  end

  @impl GenServer
  def handle_info(:reload_token, state) do
    update_token()
    {:noreply, state}
  end

  defp set_reload_timer(seconds) do
    Process.send_after(__MODULE__, :reload_token, :timer.seconds(seconds))
  end
end
