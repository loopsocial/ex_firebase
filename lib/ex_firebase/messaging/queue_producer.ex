defmodule ExFirebase.Messaging.QueueProducer do
  @moduledoc """
  The Producer in the Queue GenStage pipeline.
  It manages a queue of all payloads waiting to be sent.
  """

  use GenStage

  def start_link(args) do
    GenStage.start_link(__MODULE__, args, name: __MODULE__)
  end

  @spec add(map() | list()) :: :ok
  def add(payload) when is_map(payload) do
    GenServer.cast(__MODULE__, {:add_single, payload})
  end

  def add([]), do: :ok

  def add([payload]) do
    GenServer.cast(__MODULE__, {:add_single, payload})
  end

  def add(payloads) when is_list(payloads) do
    GenServer.cast(__MODULE__, {:add_multiple, payloads})
  end

  def get_queue do
    GenServer.call(__MODULE__, :get_queue)
  end

  def get_queue_length do
    GenServer.call(__MODULE__, :get_queue_length)
  end

  def init(_args) do
    {:producer, :queue.new()}
  end

  # Adds one payload to the end of the queue
  def handle_cast({:add_single, payload}, queue) do
    {:noreply, [], :queue.in(payload, queue)}
  end

  # Adds multiple payloads to the end of the queue
  def handle_cast({:add_multiple, payloads}, queue) do
    {:noreply, [], :queue.join(queue, :queue.from_list(payloads))}
  end

  def handle_call(:get_queue, _from, queue) do
    {:reply, :queue.to_list(queue), [], queue}
  end

  def handle_call(:get_queue_length, _from, queue) do
    {:reply, :queue.len(queue), [], queue}
  end

  # Demand was requested but the queue is empty
  def handle_demand(_demand, {[], []} = queue) do
    {:noreply, [], queue}
  end

  # Demand for 1 was requested, send 1 payload and remove it from queue
  def handle_demand(1, queue) do
    {{:value, payload}, queue} = :queue.out(queue)
    {:noreply, [payload], queue}
  end

  # Demand for n was requested, send up to n payloads if available
  def handle_demand(demand, queue) when demand > 0 do
    {payloads, queue} = split(demand, queue)
    {:noreply, :queue.to_list(payloads), queue}
  end

  defp split(n, queue) do
    length = :queue.len(queue)

    if length >= n do
      :queue.split(n, queue)
    else
      :queue.split(length, queue)
    end
  end
end
