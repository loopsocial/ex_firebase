use Mix.Config

if File.exists?("config/#{Mix.env()}.exs"), do: import_config("#{Mix.env()}.exs")
if File.exists?("config/#{Mix.env()}.secret.exs"), do: import_config("#{Mix.env()}.secret.exs")
