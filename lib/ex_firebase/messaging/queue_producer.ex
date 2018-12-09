defmodule ExFirebase.Messaging.QueueProducer do
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

  def init(_args) do
    {:producer, :queue.new()}
  end

  def handle_cast({:add_single, payload}, queue) do
    {:noreply, [], :queue.in(payload, queue)}
  end

  def handle_cast({:add_multiple, payloads}, queue) do
    {:noreply, [], :queue.join(queue, :queue.from_list(payloads))}
  end

  def handle_demand(_demand, {[], []} = queue) do
    {:noreply, [], queue}
  end

  def handle_demand(1, queue) do
    {{:value, payload}, queue} = :queue.out(queue)
    {:noreply, [payload], queue}
  end

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
