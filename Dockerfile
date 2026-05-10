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
ENV OPENCLAW_PRIMARY_MODEL=openai-codex/gpt-5.5

EXPOSE 8080

ENTRYPOINT []

RUN cat > /usr/local/bin/openclaw-railway-start <<'SH'
#!/bin/sh
set -eu

echo "[bootstrap] START openclaw-railway-start"

mkdir -p /data/.openclaw /data/workspace

node <<'NODE'
const fs = require("fs");
const path = require("path");

const configPath = process.env.OPENCLAW_CONFIG_PATH || "/data/.openclaw/openclaw.json";
const configDir = path.dirname(configPath);

fs.mkdirSync(configDir, { recursive: true });

let cfg = {};
try {
  if (fs.existsSync(configPath)) {
    cfg = JSON.parse(fs.readFileSync(configPath, "utf8"));
  }
} catch (err) {
  console.error("[bootstrap] Existing config is invalid JSON. Backing up:", err.message);
  try {
    fs.copyFileSync(configPath, `${configPath}.broken-${Date.now()}`);
  } catch (_) {}
  cfg = {};
}

const publicDomain =
  process.env.RAILWAY_PUBLIC_DOMAIN ||
  "openclaw-production-b6bf.up.railway.app";

const publicOrigin = `https://${publicDomain}`;
const gatewayPort = Number(process.env.OPENCLAW_GATEWAY_PORT || 8080);
const gatewayToken = process.env.OPENCLAW_GATEWAY_TOKEN || "";
const primaryModel = process.env.OPENCLAW_PRIMARY_MODEL || "openai-codex/gpt-5.5";
const telegramToken = process.env.TELEGRAM_BOT_TOKEN || "";

/**
 * Gateway
 */
cfg.gateway = cfg.gateway || {};
cfg.gateway.mode = "local";
cfg.gateway.bind = "lan";
cfg.gateway.port = gatewayPort;

cfg.gateway.auth = cfg.gateway.auth || {};
cfg.gateway.auth.mode = "token";

if (gatewayToken) {
  cfg.gateway.auth.token = gatewayToken;
}

cfg.gateway.controlUi = cfg.gateway.controlUi || {};
cfg.gateway.controlUi.enabled = true;
cfg.gateway.controlUi.basePath = "/openclaw";
cfg.gateway.controlUi.allowedOrigins = Array.from(
  new Set([
    publicOrigin,
    "https://openclaw-production-b6bf.up.railway.app",
    ...(cfg.gateway.controlUi.allowedOrigins || []),
  ])
);

/**
 * Critical model fix.
 * Codex OAuth requires openai-codex/*, not openai/*.
 */
cfg.agents = cfg.agents || {};
cfg.agents.defaults = cfg.agents.defaults || {};
cfg.agents.defaults.model = cfg.agents.defaults.model || {};
cfg.agents.defaults.model.primary = primaryModel;
cfg.agents.defaults.model.fallbacks = [primaryModel];

/**
 * Telegram
 */
cfg.channels = cfg.channels || {};
cfg.channels.telegram = cfg.channels.telegram || {};
cfg.channels.telegram.enabled = true;

if (telegramToken) {
  cfg.channels.telegram.botToken = telegramToken;
}

cfg.channels.telegram.dmPolicy = cfg.channels.telegram.dmPolicy || "pairing";
cfg.channels.telegram.dms = cfg.channels.telegram.dms !== false;
cfg.channels.telegram.groupPolicy = cfg.channels.telegram.groupPolicy || "open";
cfg.channels.telegram.streaming = cfg.channels.telegram.streaming || "partial";

/**
 * Bind Telegram default account to main agent.
 */
cfg.bindings = Array.isArray(cfg.bindings) ? cfg.bindings : [];

const hasTelegramBinding = cfg.bindings.some((binding) => {
  return (
    binding &&
    binding.agentId === "main" &&
    binding.match &&
    binding.match.channel === "telegram" &&
    (binding.match.accountId || "default") === "default"
  );
});

if (!hasTelegramBinding) {
  cfg.bindings.push({
    agentId: "main",
    match: {
      channel: "telegram",
      accountId: "default"
    }
  });
}

/**
 * Metadata to avoid tiny/empty config anomaly.
 */
cfg.meta = cfg.meta || {};
cfg.meta.managedBy = "railway-openclaw-bootstrap";
cfg.meta.updatedAt = new Date().toISOString();

fs.writeFileSync(configPath, JSON.stringify(cfg, null, 2));

console.log("[bootstrap] config:", configPath);
console.log("[bootstrap] primary model:", cfg.agents.defaults.model.primary);
console.log("[bootstrap] telegram enabled:", cfg.channels.telegram.enabled);
console.log("[bootstrap] telegram token:", telegramToken ? "set" : "MISSING");
console.log("[bootstrap] bindings:", JSON.stringify(cfg.bindings));
NODE

echo "[bootstrap] verify model from config:"
openclaw config get agents.defaults.model.primary || true

echo "[bootstrap] verify telegram enabled:"
openclaw config get channels.telegram.enabled || true

echo "[bootstrap] starting gateway..."
exec openclaw gateway run --port "${OPENCLAW_GATEWAY_PORT:-8080}" --bind lan --allow-unconfigured
SH

RUN chmod +x /usr/local/bin/openclaw-railway-start

CMD ["/usr/local/bin/openclaw-railway-start"]
