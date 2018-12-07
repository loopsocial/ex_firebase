defmodule ExFirebase do
  @moduledoc """
  A limited Firebase Admin SDK implementation
  """
  def project_id do
    Application.get_env(:ex_firebase, :project_id)
  end
end

defmodule ExFirebase.Error do
  defstruct [:reason]
  @type t :: %__MODULE__{reason: any()}
end

defmodule ExFirebase.HTTPResponse do
  defstruct [:status_code, :body, headers: []]
  @type headers :: [{binary(), binary()}]
  @type t :: %__MODULE__{status_code: integer(), body: any(), headers: headers()}
end

defmodule ExFirebase.HTTPError do
  defstruct [:reason]
  @type t :: %__MODULE__{reason: any()}
end
