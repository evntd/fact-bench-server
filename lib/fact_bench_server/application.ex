defmodule FactBenchServer.Application do
  use Application

  require Logger

  @impl true
  def start(_type, _args) do
    db_path = Application.get_env(:fact_bench_server, :db_path, "/data/benchmark")
    port = Application.get_env(:fact_bench_server, :port, 4000)

    ensure_database_created(db_path)

    {:ok, db_id} = Fact.open(db_path)
    :persistent_term.put(:fact_db_id, db_id)

    Logger.info("Fact database opened: #{db_id} at #{db_path}")

    children = [
      {GRPC.Server.Supervisor, endpoint: FactBenchServer.Endpoint, port: port, start_server: true}
    ]

    opts = [strategy: :one_for_one, name: FactBenchServer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp ensure_database_created(db_path) do
    bootstrap_path = Path.join(db_path, ".bootstrap")

    unless File.exists?(bootstrap_path) do
      Logger.info("Creating new Fact database at #{db_path}")
      File.mkdir_p!(db_path)

      alias Fact.Genesis.Command.CreateDatabase
      alias Fact.Genesis.Decider
      alias Fact.Genesis.TheCreator

      command = %CreateDatabase.V1{args: [path: db_path]}
      {:ok, [event]} = Decider.decide(Decider.initial_state(), command)
      TheCreator.let_there_be_light(event)
    end
  end
end
