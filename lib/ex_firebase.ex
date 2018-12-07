defmodule ExFirebase do
  @moduledoc """
  A limited Firebase Admin SDK implementation
  """
  def project_id do
    Application.get_env(:ex_firebase, :project_id)
  end
end
