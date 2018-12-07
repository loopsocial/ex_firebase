defmodule ExFirebase.Messaging do
  alias ExFirebase.{Auth, Error}

  @http_module Application.get_env(:ex_firebase, :messaging_http_module)

  @doc """
  Sends a message with Firebase Cloud Messaging v1 API

  ## Examples

      iex> ExFirebase.Messaging.send_message(%{message: %{token: "dyZHH...", notification: %{body: "Hello World"}}})
      {:ok,
       %HTTPoison.Response{
         body: %{
           "name" => "projects/myproject-id/messages/0:1544204830625699%2575e27c2575e27c"
         },
         ...
         status_code: 200
       }}
  """
  @spec send_message(map()) ::
          {:ok, HTTPResponse.t()}
          | {:error, HTTPoison.Error.t()}
          | {:error, Error.t()}
  def send_message(body) when is_map(body) do
    if ExFirebase.project_id() do
      with {:ok, access_token} <- Auth.get_access_token() do
        @http_module.send_message(body, access_token)
      end
    else
      {:error, %Error{reason: :no_project_id}}
    end
  end
end
