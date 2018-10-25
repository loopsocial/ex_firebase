defmodule Firebase.MixProject do
  use Mix.Project

  def project do
    [
      app: :firebase,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {Firebase.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:jose, "~> 1.8"},
      {:poison, "~> 3.1"},
      {:httpoison, "~> 1.4"}
    ]
  end
end
