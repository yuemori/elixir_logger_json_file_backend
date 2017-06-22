defmodule LoggerJSONFileBackend.Mixfile do
  use Mix.Project

  def project do
    [app: :logger_json_file_backend,
     version: "0.1.6",
     description: "Logger backend that write a json map per line to a file",
     elixir: "~> 1.2",
     package: package(),
     deps: deps()]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:poison, "~> 1.5 or ~> 2.0"},
      {:uuid, "~> 1.1"},
      {:json, "~> 0.3.2", only: :test},
      {:ex_doc, ">= 0.0.0", only: :dev},
    ]
  end

  defp package do
    [
      maintainers: ["Hidetaka Kojo", "Lei Yuan", "Hiroaki Murayama"],
      licenses: ["ISC"],
      links: %{"GitHub" => "https://github.com/xflagstudio/elixir_logger_json_file_backend"}
    ]
  end
end
