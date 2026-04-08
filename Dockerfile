# Build stage
FROM elixir:1.17-otp-27-alpine AS build

RUN apk add --no-cache build-base git

WORKDIR /app

# Install hex and rebar
RUN mix local.hex --force && mix local.rebar --force

# Install deps first (cacheable layer)
ENV MIX_ENV=prod
COPY mix.exs mix.lock ./
RUN mix deps.get --only prod && mix deps.compile

# Copy application code
COPY config config
COPY lib lib
COPY priv priv

RUN mix release

# Runtime stage
FROM alpine:3.22

RUN apk add --no-cache libstdc++ ncurses-libs openssl

WORKDIR /app
COPY --from=build /app/_build/prod/rel/fact_bench_server ./

ENV FACT_DB_PATH=/data/benchmark
EXPOSE 4000/tcp

CMD ["bin/fact_bench_server", "start"]
