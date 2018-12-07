use Mix.Config

config :ex_firebase,
  auth_http_module: ExFirebase.Auth.HTTP,
  messaging_http_module: ExFirebase.Messaging.HTTP

if File.exists?("config/#{Mix.env()}.exs"), do: import_config("#{Mix.env()}.exs")
if File.exists?("config/#{Mix.env()}.secret.exs"), do: import_config("#{Mix.env()}.secret.exs")
