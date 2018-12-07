defmodule ExFirebase.Messaging do
  alias ExFirebase.{Auth, Error}

  @http_module Application.get_env(:ex_firebase, :messaging_http_module) ||
                 ExFirebase.Messaging.HTTP

  @doc """
  Sends a push notification with Firebase Cloud Messaging v1 API

  ## Examples

      iex> ExFirebase.Messaging.send(%{message: %{token: "dyZHH...", notification: %{body: "Hello World"}}})
      {:ok,
       %HTTPoison.Response{
         body: %{
           "name" => "projects/project-id/messages/0:1544204830625699%2575e27c2575e27c"
         },
         ...
         status_code: 200
       }}
  """
  @spec send(map()) ::
          {:ok, HTTPResponse.t()}
          | {:error, HTTPoison.Error.t()}
          | {:error, Error.t()}
  def send(body) when is_map(body) do
    if ExFirebase.project_id() do
      with {:ok, access_token} <- Auth.get_access_token() do
        @http_module.send(body, access_token)
      end
    else
      {:error, %Error{reason: :no_project_id}}
    end
  end
end
