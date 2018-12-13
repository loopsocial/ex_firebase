use Mix.Config

config :ex_firebase,
  project_id: "project-id",
  auth_api: ExFirebase.Auth.APIMock,
  messaging_api: ExFirebase.Messaging.APIMock,
  service_account_path: Path.join(File.cwd!(), "/test/fixtures/service-account.json")
