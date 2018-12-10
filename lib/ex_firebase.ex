defmodule ExFirebase do
  @moduledoc """
  Firebase Admin SDK
  """

  use Application

  def start(_type, _args) do
    children = [
      ExFirebase.Auth.AccessTokenManager,
      ExFirebase.Auth.PublicKeyManager,
      ExFirebase.Messaging.QueueProducer,
      ExFirebase.Messaging.QueueProducerConsumer,
      ExFirebase.Messaging.QueueConsumerSupervisor,
      ExFirebase.Messaging.Scheduler,
      ExFirebase.Messaging.QueueMonitor
    ]

    opts = [strategy: :one_for_one, name: ExFirebase.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
