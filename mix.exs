defmodule LoggerJSONFileBackend.Mixfile do
  use Mix.Project

  def project do
    [app: :logger_json_file_backend,
     version: "0.1.9",
     description: "Logger backend that write a json map per line to a file",
     elixir: "~> 1.4",
     package: package(),
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:jason, "~> 1.0", optional: true},
      {:elixir_uuid, "~> 1.2"},
      {:poison, "~> 3.0", only: :test},
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
