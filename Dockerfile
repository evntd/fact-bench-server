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

RUN addgroup -g 1000 app && adduser -D -u 1000 -G app app

WORKDIR /app
COPY --from=build --chown=app:app /app/_build/prod/rel/fact_bench_server ./

RUN mkdir -p /data/benchmark && chown -R app:app /data

USER app

ENV FACT_DB_PATH=/data/benchmark
EXPOSE 4000/tcp

CMD ["bin/fact_bench_server", "start"]
