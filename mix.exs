defmodule ExFirebase.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_firebase,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {ExFirebase.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:jose, "~> 1.8"},
      {:poison, "~> 3.1"},
      {:httpoison, "~> 1.4"},
      {:mock, "~> 0.3.2", only: :test}
    ]
  end
end
