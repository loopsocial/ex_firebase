use Mix.Config

config :logger, level: :warn

config :ex_firebase,
  auth_http_client: ExFirebase.Auth.HTTPMock,
  service_account_key_path: Path.join(File.cwd!(), "/test/fixtures/service_account_key.json")
