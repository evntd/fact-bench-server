import Config

config :fact_bench_server,
  db_path: System.get_env("FACT_DB_PATH", "/data/benchmark"),
  port: String.to_integer(System.get_env("PORT", "4000"))
