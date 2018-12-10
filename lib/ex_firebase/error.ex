defmodule ExFirebase.Error do
  defexception [:reason]

  @type t :: %__MODULE__{reason: any()}

  def message(%__MODULE__{reason: reason}), do: inspect(reason)
end
