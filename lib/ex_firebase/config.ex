defmodule ExFirebase.Config do
  def project_id do
    Application.get_env(:ex_firebase, :project_id)
  end
end
