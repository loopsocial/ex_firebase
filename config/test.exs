use Mix.Config

config :logger, level: :warn

config :ex_firebase,
  auth_http_module: ExFirebase.Auth.HTTPMock,
  messaging_http_module: ExFirebase.Messaging.HTTPMock,
  service_account_key_path: Path.join(File.cwd!(), "/test/fixtures/service_account_key.json")
