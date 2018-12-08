defmodule ExFirebase do
  @moduledoc """
  Firebase Admin SDK
  """
  use Application

  def start(_type, _args) do
    children = [
      ExFirebase.Auth.AccessTokenManager,
      ExFirebase.Auth.PublicKeyManager
    ]

    opts = [strategy: :one_for_one, name: ExFirebase.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def project_id do
    Application.get_env(:ex_firebase, :project_id)
  end
end
