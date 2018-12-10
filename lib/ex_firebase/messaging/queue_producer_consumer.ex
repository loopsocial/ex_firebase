defmodule ExFirebase.Messaging.QueueProducerConsumer do
  @moduledoc """
  The ProducerConsumer in the Queue GenStage pipeline.
  It acts as an internal rate limiter for FCM requests.
  """

  use GenStage

  alias ExFirebase.Messaging.QueueProducer

  @default_interval 500
  @default_batch_size 10
  # How often to ask the QueueProducer for messages
  @interval_ms Application.get_env(:ex_firebase, :queue_interval) || @default_interval
  # How many messages to attempt sending per @interval_ms
  @max_demand Application.get_env(:ex_firebase, :queue_batch_size) || @default_batch_size

  def start_link(args) do
    GenStage.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    {:producer_consumer, %{}, subscribe_to: [QueueProducer]}
  end

  def handle_subscribe(:producer, _opts, from, _state) do
    # Schedule initial request for messages
    Process.send_after(__MODULE__, :ask, @interval_ms)
    # This process is responsible for requesting its demand
    {:manual, %{producer: from}}
  end

  def handle_subscribe(:consumer, _opts, _from, state) do
    # The ConsumerSupervisor is responsible for requesting its demand
    {:automatic, state}
  end

  def handle_info(:ask, %{producer: producer} = state) do
    # Request up to our @max_demand from QueueProducer
    GenStage.ask(producer, @max_demand)
    # Schedule next request
    Process.send_after(__MODULE__, :ask, @interval_ms)
    {:noreply, [], state}
  end

  # Demand sent from QueueProducer is forwarded to ConsumerSupervisor
  def handle_events(events, _from, state) do
    {:noreply, events, state}
  end
end
