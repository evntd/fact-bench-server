defmodule FactBenchServer.Endpoint do
  use GRPC.Endpoint

  intercept GRPC.Server.Interceptors.Logger

  run FactBenchServer.Server
end
