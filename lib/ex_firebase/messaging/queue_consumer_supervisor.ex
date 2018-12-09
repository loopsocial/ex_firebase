defmodule ExFirebase.Messaging.QueueConsumerSupervisor do
  use ConsumerSupervisor

  alias ExFirebase.Messaging.{QueueConsumer, QueueProducerConsumer}

  def start_link(args) do
    ConsumerSupervisor.start_link(__MODULE__, args)
  end

  def init(_args) do
    ConsumerSupervisor.init([QueueConsumer],
      strategy: :one_for_one,
      subscribe_to: [QueueProducerConsumer]
    )
  end
end
