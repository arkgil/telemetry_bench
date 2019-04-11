defmodule TelemetryBench.MixProject do
  use Mix.Project

  def project do
    [
      app: :telemetry_bench,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:telemetry, path: "../telemetry/telemetry"}
    ]
  end

  defp aliases() do
    [
      bench: "run bench.exs"
    ]
  end
end
