use Mix.Config

config :ex_firebase,
  auth_http_module: ExFirebase.Auth.HTTPMock,
  messaging_http_module: ExFirebase.Messaging.HTTPMock,
  service_account_path: Path.join(File.cwd!(), "/test/fixtures/service-account.json")
