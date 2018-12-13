defmodule ExFirebase.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_firebase,
      version: "0.2.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      docs: docs(),
      package: package(),
      name: "ExFirebase",
      description: "Lightweight Firebase Admin SDK",
      source_url: "https://github.com/loopsocial/ex_firebase"
    ]
  end

  def application do
    [
      mod: {ExFirebase, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:jose, "~> 1.8"},
      {:poison, "~> 3.1"},
      {:httpoison, "~> 1.4"},
      {:gen_stage, "~> 0.14.1"},
      {:gproc, "~> 0.5.0"},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0.0-rc.4", only: [:dev], runtime: false}
    ]
  end

  defp docs do
    [
      main: "ExFirebase",
      extras: ["README.md"]
    ]
  end

  defp package do
    [
      name: :ex_firebase,
      maintainers: ["Ben Hansen"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/loopsocial/ex_firebase"}
    ]
  end

  defp elixirc_paths(:test), do: ["test/support", "lib"]
  defp elixirc_paths(_), do: ["lib"]
end
