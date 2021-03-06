defmodule ExFirebase.Assertions do
  @moduledoc """
  ExUnit.Assertion Helpers
  """

  alias ExFirebase.Messaging

  @spec assert_in_queue(map()) :: :ok | ExUnit.AssertionError.t()
  def assert_in_queue(payload) do
    case in_queue?(payload) do
      true ->
        :ok

      false ->
        raise ExUnit.AssertionError,
          message:
            "Expected payload to be in queue. \npayload: #{inspect(payload)}\nqueue: #{
              inspect(ExFirebase.Messaging.get_queue())
            }"
    end
  end

  @spec refute_in_queue(map()) :: :ok | ExUnit.AssertionError.t()
  def refute_in_queue(payload) do
    case in_queue?(payload) do
      false ->
        :ok

      true ->
        raise ExUnit.AssertionError,
          message:
            "Did not expect payload to be in queue. \npayload: #{inspect(payload)}\nqueue: #{
              inspect(ExFirebase.Messaging.get_queue())
            }"
    end
  end

  @spec in_queue?(map()) :: boolean()
  def in_queue?(payload) do
    Messaging.get_queue()
    |> Enum.reduce([], fn p, acc ->
      comparisons =
        payload
        |> key_paths_with_values()
        |> Enum.map(fn {keys, value} ->
          value == get_in(p, keys)
        end)

      case Enum.all?(comparisons, & &1) do
        true -> [true | acc]
        false -> acc
      end
    end)
    |> Enum.any?(& &1)
  end

  defp key_paths_with_values(map, keys \\ [], results \\ []) do
    map
    |> Map.keys()
    |> Enum.reduce(results, fn key, acc ->
      if is_map(map[key]) do
        key_paths_with_values(map[key], [key | keys], acc)
      else
        [{Enum.reverse([key | keys]), map[key]} | acc]
      end
    end)
  end
end
