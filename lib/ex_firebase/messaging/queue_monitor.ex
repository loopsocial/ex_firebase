defmodule ExFirebase.Messaging.QueueMonitor do
  @moduledoc """
  Listens to events from :fcm_queue_monitor process to track metrics.
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
    :gproc.reg({:p, :l, :fcm_queue_monitor})
    {:ok, %{attempts: 0, successes: 0, failures: 0}}
  end

  @spec get_stats :: state()
  def get_stats do
    GenServer.call(__MODULE__, :get_stats)
  end

  @impl GenServer
  def handle_call(:get_stats, _from, state) do
    {:reply, state, state}
  end

  @impl GenServer
  def handle_info({:request, _payload}, state) do
    {:noreply, %{state | attempts: state[:attempts] + 1}}
  end

  @impl GenServer
  def handle_info({:response, {:ok, %HTTPoison.Response{status_code: 200}}, _payload}, state) do
    {:noreply, %{state | successes: state[:successes] + 1}}
  end

  @impl GenServer
  def handle_info({:response, _, _}, state) do
    {:noreply, %{state | failures: state[:failures] + 1}}
  end

  @impl GenServer
  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
