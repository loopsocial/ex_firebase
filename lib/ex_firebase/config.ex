defmodule ExFirebase.Config do
  def project_id do
    Application.get_env(:ex_firebase, :project_id)
  end

  def service_account_path do
    Application.get_env(:ex_firebase, :service_account_path)
  end

  def private_key do
    Application.get_env(:ex_firebase, :private_key)
  end

  def client_email do
    Application.get_env(:ex_firebase, :client_email)
  end
end
