defmodule ExFirebase.Error do
  defstruct [:reason]
  @type t :: %__MODULE__{reason: any()}
end
