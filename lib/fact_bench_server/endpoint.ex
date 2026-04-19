defmodule FactBenchServer.Endpoint do
  use GRPC.Endpoint

  run FactBenchServer.Server
end
