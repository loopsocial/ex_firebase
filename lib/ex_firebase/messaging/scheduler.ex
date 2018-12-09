defmodule ExFirebase.Messaging.Scheduler do
  use GenServer

  alias ExFirebase.Messaging

  @interval_ms 60 * 1000

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def schedule(payload, seconds) when seconds > 0 do
    GenServer.cast(
      __MODULE__,
      {:schedule, payload, Timex.shift(DateTime.utc_now(), seconds: seconds)}
    )
  end

  defp send_scheduled do
    GenServer.cast(__MODULE__, :send_scheduled)
  end

  @impl GenServer
  def init(_args) do
    Process.send_after(__MODULE__, :check_schedule, @interval_ms)
    {:ok, []}
  end

  @impl GenServer
  def handle_cast({:schedule, payload, seconds}, state) do
    {:noreply, [{payload, seconds} | state]}
  end

  @impl GenServer
  def handle_cast(:send_scheduled, state) do
    {scheduled, state} =
      Enum.split_with(state, fn {_, dt} ->
        Timex.compare(dt, DateTime.utc_now()) == -1
      end)

    scheduled
    |> Enum.map(fn {payload, _} -> payload end)
    |> Messaging.queue()

    Process.send_after(__MODULE__, :check_schedule, @interval_ms)
    {:noreply, state}
  end

  @impl GenServer
  def handle_info(:check_schedule, state) do
    send_scheduled()
    {:noreply, state}
  end
end
