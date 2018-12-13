defmodule ExFirebase.Messaging.QueueConsumer do
  @moduledoc """
  The final consumer in the Queue GenStage pipeline.
  Requests & responses are broadcast through the `:gproc` registered process `:fcm_queue_monitor`.
  """

  alias ExFirebase.Messaging

  def start_link(payload) do
    Task.start_link(fn ->
      :gproc.send({:p, :l, :fcm_queue_monitor}, {:request, payload})
      response = Messaging.send(payload)
      :gproc.send({:p, :l, :fcm_queue_monitor}, {:response, response, payload})
    end)
  end

  def child_spec(_args) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      restart: :temporary
    }
  end
end
