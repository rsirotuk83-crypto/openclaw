FROM ghcr.io/openclaw/openclaw:latest

USER root

RUN mkdir -p /data/.openclaw /data/workspace \
  && chmod -R 777 /data

ENV NODE_ENV=production
ENV PORT=8080
ENV OPENCLAW_GATEWAY_PORT=8080
ENV OPENCLAW_STATE_DIR=/data/.openclaw
ENV OPENCLAW_WORKSPACE_DIR=/data/workspace
ENV OPENCLAW_CONFIG_PATH=/data/.openclaw/openclaw.json

EXPOSE 8080

ENTRYPOINT []

CMD set -eu; \
  mkdir -p /data/.openclaw /data/workspace; \
  node -e 'const fs = require("fs"); const port = Number(process.env.OPENCLAW_GATEWAY_PORT || 8080); const publicDomain = process.env.RAILWAY_PUBLIC_DOMAIN || "openclaw-production-b6bf.up.railway.app"; const origin = "https://" + publicDomain; const token = process.env.OPENCLAW_GATEWAY_TOKEN || ""; const cfg = { gateway: { mode: "local", bind: "lan", port, auth: { mode: "token", token }, controlUi: { enabled: true, basePath: "/openclaw", allowedOrigins: [origin, "https://openclaw-production-b6bf.up.railway.app"] } } }; fs.writeFileSync(process.env.OPENCLAW_CONFIG_PATH || "/data/.openclaw/openclaw.json", JSON.stringify(cfg, null, 2));'; \
  exec openclaw gateway run --port "${OPENCLAW_GATEWAY_PORT:-8080}" --bind lan --allow-unconfigured
