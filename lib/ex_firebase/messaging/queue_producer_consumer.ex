defmodule ExFirebase.Messaging.QueueProducerConsumer do
  use GenStage

  alias ExFirebase.Messaging.QueueProducer

  # How often to ask the QueueProducer for messages
  @ask_interval 1000
  # How many messages to attempt sending per @ask_interval
  @max_demand 2

  def start_link(args) do
    GenStage.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    {:producer_consumer, %{}, subscribe_to: [QueueProducer]}
  end

  def handle_subscribe(:producer, _opts, from, _state) do
    Process.send_after(__MODULE__, :ask, @ask_interval)
    {:manual, %{producer: from}}
  end

  def handle_subscribe(:consumer, _opts, _from, state) do
    {:automatic, state}
  end

  def handle_info(:ask, %{producer: producer} = state) do
    GenStage.ask(producer, @max_demand)
    Process.send_after(__MODULE__, :ask, @ask_interval)
    {:noreply, [], state}
  end

  def handle_events(events, _from, state) do
    {:noreply, events, state}
  end
end
