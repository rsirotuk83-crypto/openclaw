FROM node:22-bookworm

RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    python3 \
    build-essential \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY patches ./patches
COPY scripts ./scripts

RUN corepack enable \
  && corepack prepare pnpm@10.12.4 --activate \
  && pnpm install --frozen-lockfile

COPY . .

RUN pnpm build || true

ENV NODE_ENV=production
ENV PORT=8080
ENV OPENCLAW_GATEWAY_PORT=8080

EXPOSE 8080

CMD ["pnpm", "openclaw", "gateway", "run", "--port", "8080"]
