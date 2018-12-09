defmodule ExFirebase.Messaging.QueueProducerConsumer do
  use GenStage

  alias ExFirebase.Messaging.QueueProducer

  # How often to ask the QueueProducer for messages
  @interval_ms Application.get_env(:ex_firebase, :queue_interval) || 1000
  # How many messages to attempt sending per @interval_ms
  @max_demand Application.get_env(:ex_firebase, :queue_batch_size) || 10

  def start_link(args) do
    GenStage.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    {:producer_consumer, %{}, subscribe_to: [QueueProducer]}
  end

  def handle_subscribe(:producer, _opts, from, _state) do
    # Schedule initial request for messages
    Process.send_after(__MODULE__, :ask, @interval_ms)
    # Make this process responsible for managing its state
    {:manual, %{producer: from}}
  end

  def handle_subscribe(:consumer, _opts, _from, state) do
    # The consumer will be responsible for its state
    {:automatic, state}
  end

  def handle_info(:ask, %{producer: producer} = state) do
    # Request up to our demand limit from QueueProducer
    GenStage.ask(producer, @max_demand)
    # Schedule next ask request
    Process.send_after(__MODULE__, :ask, @interval_ms)
    {:noreply, [], state}
  end

  # Demand from QueueProducer is forwarded straight to our consumer
  def handle_events(events, _from, state) do
    {:noreply, events, state}
  end
end
