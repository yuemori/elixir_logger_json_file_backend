defmodule LoggerJSONFileBackendTest do
  use ExUnit.Case, async: false
  require Logger

  @backend {LoggerJSONFileBackend, :test}
  Logger.add_backend @backend

  setup do
    config [path: "test/logs/test.log", level: :debug]
    on_exit fn ->
      path && File.rm_rf!(Path.dirname(path))
    end
  end

  test "create log file" do
    refute File.exists?(path)
    Logger.debug("msg body", [foo: "bar", baz: []])
    assert File.exists?(path)
  end

  defp path do
    {:ok, path} = GenEvent.call(Logger, @backend, :path)
    path
  end

  defp log do
    File.read!(path)
  end

  defp config(opts) do
    Logger.configure_backend(@backend, opts)
  end
end
