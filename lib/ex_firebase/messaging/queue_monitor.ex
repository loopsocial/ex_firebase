defmodule ExFirebase.Messaging.QueueMonitor do
  @moduledoc """
  GenStage process that intercepts all request and responses from QueueConsumer
  """

  use GenServer

  @type fcm_result ::
          {:ok, map(), map()}
          | {:retry, map(), map()}
          | {:error, any(), map()}

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    {:ok, nil}
  end

  @spec fcm_request(map()) :: :ok
  def fcm_request(request) do
    GenServer.cast(__MODULE__, {:request, request})
  end

  @spec fcm_response(fcm_result()) :: :ok
  def fcm_response(response) do
    GenServer.cast(__MODULE__, {:response, response})
  end

  def handle_cast(_request, state) do
    {:noreply, state}
  end
end
