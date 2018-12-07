defmodule ExFirebase.Messaging.HTTPMock do
  @behaviour ExFirebase.Messaging.HTTP

  def send_message(_body, _access_token) do
    {:ok,
     %HTTPoison.Response{
       body: %{},
       headers: [],
       status_code: 201
     }}
  end
end
