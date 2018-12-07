defmodule ExFirebase.Application do
  use Application

  def start(_type, _args) do
    children = [
      ExFirebase.Auth.AccessTokenManager,
      ExFirebase.Auth.PublicKeyManager
    ]

    opts = [strategy: :one_for_one, name: ExFirebase.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
