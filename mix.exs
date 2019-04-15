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
      {:telemetry, github: "beam-telemetry/telemetry"},
      {:benchee, "~> 1.0"}
    ]
  end

  defp aliases() do
    [
      bench_v1: "run bench_v1.exs",
      bench_v2: "run bench_v2.exs",
      bench_v3: "run bench_v3.exs"
    ]
  end
end
