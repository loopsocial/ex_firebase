defmodule ExFirebase.Messaging.QueueMonitor do
  @moduledoc """
  GenServer process that listens to events from QueueConsumer to track metrics.
  Events are simultaneously broadcast through the `:gproc` registered process `:fcm_queue_monitor`.
  """

  use GenServer

  @type state :: %{
          attempts: integer(),
          successes: integer(),
          failures: integer()
        }

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl GenServer
  def init(_args) do
    {:ok, %{attempts: 0, successes: 0, failures: 0}}
  end

  @spec stats :: state()
  def stats do
    GenServer.call(__MODULE__, :stats)
  end

  @spec fcm_request(map()) :: :ok
  def fcm_request(payload) do
    msg = {:request, payload}
    :gproc.send({:p, :l, :fcm_queue_monitor}, msg)
    GenServer.cast(__MODULE__, msg)
  end

  @spec fcm_response({:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}, map()) :: :ok
  def fcm_response(response, payload) do
    msg = {:response, response, payload}
    :gproc.send({:p, :l, :fcm_queue_monitor}, msg)
    GenServer.cast(__MODULE__, msg)
  end

  @impl GenServer
  def handle_call(:stats, _from, state) do
    {:reply, state, state}
  end

  @impl GenServer
  def handle_cast({:request, _payload}, state) do
    {:noreply, %{state | attempts: state[:attempts] + 1}}
  end

  @impl GenServer
  def handle_cast({:response, {:ok, %HTTPoison.Response{status_code: 200}}, _payload}, state) do
    {:noreply, %{state | successes: state[:successes] + 1}}
  end

  @impl GenServer
  def handle_cast({:response, _, _}, state) do
    {:noreply, %{state | failures: state[:failures] + 1}}
  end
end
