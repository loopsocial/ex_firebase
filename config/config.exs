use Mix.Config

config :ex_firebase, :auth_http_client, ExFirebase.Auth.HTTP

if File.exists?("config/#{Mix.env()}.exs"), do: import_config("#{Mix.env()}.exs")
