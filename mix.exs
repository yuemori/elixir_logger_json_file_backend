defmodule LoggerJSONFileBackend.Mixfile do
  use Mix.Project

  def project do
    [app: :logger_json_file_backend,
     version: "0.1.2",
     description: "Logger backend that write a json map per line to a file",
     elixir: "~> 1.2",
     package: package,
     deps: deps]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:poison, "~> 1.5 or ~> 2.0"},
      {:json, "~> 0.3.2", only: :test}
    ]
  end

  defp package do
    [
      maintainers: ["Hidetaka Kojo"],
      licenses: ["ISC"],
      links: %{"GitHub" => "https://github.com/xflagstudio/elixir_logger_json_file_backend"}
    ]
  end
end
