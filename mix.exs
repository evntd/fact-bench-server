defmodule FactBenchServer.MixProject do
  use Mix.Project

  def project do
    [
      app: :fact_bench_server,
      version: "0.3.1",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {FactBenchServer.Application, []}
    ]
  end

  defp deps do
    [
      {:fact, "~> 0.3.1"},
      {:grpc, "~> 0.9"},
      {:protobuf, "~> 0.13"},
      {:jason, "~> 1.4"}
    ]
  end
end
