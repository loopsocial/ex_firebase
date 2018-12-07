use Mix.Config

config :ex_firebase,
  project_id: "project-id",
  auth_http_module: ExFirebase.Auth.HTTPMock,
  messaging_http_module: ExFirebase.Messaging.HTTPMock,
  service_account_path: Path.join(File.cwd!(), "/test/fixtures/service-account.json")
