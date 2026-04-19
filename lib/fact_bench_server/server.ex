defmodule FactBenchServer.Server do
  use GRPC.Server, service: Fact.Bench.FactBench.Service

  def healthz(_request, _stream) do
    db_id = :persistent_term.get(:fact_db_id, nil)

    status =
      if db_id && GenServer.whereis(Fact.Registry.via(db_id, Fact.Database)) do
        "ok"
      else
        "starting"
      end

    %Fact.Bench.HealthzResponse{status: status}
  end

  def append(request, _stream) do
    db_id = :persistent_term.get(:fact_db_id)
    raw_events = request.events

    first_tags = List.first(raw_events, %Fact.Bench.EventData{}).tags

    result =
      if first_tags != [] do
        stream_name = hd(first_tags)

        stream_events =
          Enum.map(raw_events, fn raw ->
            %{type: raw.event_type, data: raw.payload, tags: tl(raw.tags)}
          end)

        Fact.append_stream(db_id, stream_events, stream_name)
      else
        events =
          Enum.map(raw_events, fn raw ->
            %{type: raw.event_type, data: raw.payload, tags: raw.tags}
          end)

        Fact.append(db_id, events)
      end

    case result do
      {:ok, _position} ->
        %Fact.Bench.AppendResponse{ok: true}

      {:error, reason} ->
        raise GRPC.RPCError, status: :internal, message: inspect(reason)
    end
  end

  def read(request, _stream) do
    db_id = :persistent_term.get(:fact_db_id)

    opts = [direction: :forward]

    opts =
      if request.from_offset do
        Keyword.put(opts, :position, request.from_offset)
      else
        opts
      end

    opts =
      if request.limit do
        Keyword.put(opts, :count, request.limit)
      else
        opts
      end

    records = Fact.read(db_id, {:stream, request.stream}, opts)

    response_events =
      Enum.map(records, fn record ->
        %Fact.Bench.ReadEvent{
          offset: (record["stream_position"] || 1) - 1,
          event_type: record["event_type"],
          payload: record["event_data"] || "",
          timestamp_ms: div(record["store_timestamp"] || 0, 1000)
        }
      end)

    %Fact.Bench.ReadResponse{events: response_events}
  end
end
