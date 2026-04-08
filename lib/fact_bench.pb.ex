defmodule Fact.Bench.AppendRequest do
  @moduledoc false

  use Protobuf,
    full_name: "fact.bench.AppendRequest",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :events, 1, repeated: true, type: Fact.Bench.EventData
end

defmodule Fact.Bench.EventData do
  @moduledoc false

  use Protobuf,
    full_name: "fact.bench.EventData",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :payload, 1, type: :bytes
  field :event_type, 2, type: :string, json_name: "eventType"
  field :tags, 3, repeated: true, type: :string
end

defmodule Fact.Bench.AppendResponse do
  @moduledoc false

  use Protobuf,
    full_name: "fact.bench.AppendResponse",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :ok, 1, type: :bool
end

defmodule Fact.Bench.ReadRequest do
  @moduledoc false

  use Protobuf,
    full_name: "fact.bench.ReadRequest",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :stream, 1, type: :string
  field :from_offset, 2, proto3_optional: true, type: :uint64, json_name: "fromOffset"
  field :limit, 3, proto3_optional: true, type: :uint64
end

defmodule Fact.Bench.ReadResponse do
  @moduledoc false

  use Protobuf,
    full_name: "fact.bench.ReadResponse",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :events, 1, repeated: true, type: Fact.Bench.ReadEvent
end

defmodule Fact.Bench.ReadEvent do
  @moduledoc false

  use Protobuf,
    full_name: "fact.bench.ReadEvent",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :offset, 1, type: :uint64
  field :event_type, 2, type: :string, json_name: "eventType"
  field :payload, 3, type: :bytes
  field :timestamp_ms, 4, type: :uint64, json_name: "timestampMs"
end

defmodule Fact.Bench.HealthzRequest do
  @moduledoc false

  use Protobuf,
    full_name: "fact.bench.HealthzRequest",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3
end

defmodule Fact.Bench.HealthzResponse do
  @moduledoc false

  use Protobuf,
    full_name: "fact.bench.HealthzResponse",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :status, 1, type: :string
end

defmodule Fact.Bench.FactBench.Service do
  @moduledoc false

  use GRPC.Service, name: "fact.bench.FactBench", protoc_gen_elixir_version: "0.16.0"

  rpc :Append, Fact.Bench.AppendRequest, Fact.Bench.AppendResponse

  rpc :Read, Fact.Bench.ReadRequest, Fact.Bench.ReadResponse

  rpc :Healthz, Fact.Bench.HealthzRequest, Fact.Bench.HealthzResponse
end

defmodule Fact.Bench.FactBench.Stub do
  @moduledoc false

  use GRPC.Stub, service: Fact.Bench.FactBench.Service
end
