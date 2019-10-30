defmodule SingletonSupervisor.MixProject do
  use Mix.Project

  def project do
    [
      app: :singleton_supervisor,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  def application, do: []

  defp deps do
    [
      {:ex_doc, "~> 0.19", only: :dev, runtime: false}
    ]
  end

  defp description() do
    "Singleton supervisor within an erlang cluster"
  end

  defp package() do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/farhadi/singleton_supervisor"}
    ]
  end
end
