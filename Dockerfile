FROM ghcr.io/openclaw/openclaw:latest

USER root

RUN mkdir -p /data/.openclaw /data/workspace /data/workspace/memory \
  && chmod -R 777 /data

ENV NODE_ENV=production
ENV PORT=8080
ENV OPENCLAW_GATEWAY_PORT=8080
ENV OPENCLAW_STATE_DIR=/data/.openclaw
ENV OPENCLAW_CONFIG_PATH=/data/.openclaw/openclaw.json
ENV OPENCLAW_WORKSPACE_DIR=/data/workspace
ENV OPENCLAW_PRIMARY_MODEL=openai-codex/gpt-5.5
ENV OPENCLAW_COMMAND_OWNER_ALLOW_FROM=["telegram:558992465"]
ENV TRADING_MODE=research
ENV TRADING_REQUIRE_HUMAN_APPROVAL=true
ENV TRADING_PAPER_FIRST=true
ENV TRADING_MAX_DAILY_LOSS_PCT=1
ENV TRADING_MAX_POSITION_RISK_PCT=0.25

EXPOSE 8080

ENTRYPOINT []

RUN cat > /usr/local/bin/openclaw-railway-start <<'SH'
#!/bin/sh
set -eu

echo "[bootstrap] START openclaw-railway-start"

mkdir -p /data/.openclaw /data/workspace /data/workspace/memory

PRIMARY_MODEL="${OPENCLAW_PRIMARY_MODEL:-openai-codex/gpt-5.5}"
WORKSPACE_DIR="${OPENCLAW_WORKSPACE_DIR:-/data/workspace}"
GATEWAY_PORT="${OPENCLAW_GATEWAY_PORT:-8080}"
OWNER_ALLOW_FROM="${OPENCLAW_COMMAND_OWNER_ALLOW_FROM:-[\"telegram:558992465\"]}"

TRADING_MODE_VALUE="${TRADING_MODE:-research}"
TRADING_REQUIRE_HUMAN_APPROVAL_VALUE="${TRADING_REQUIRE_HUMAN_APPROVAL:-true}"
TRADING_PAPER_FIRST_VALUE="${TRADING_PAPER_FIRST:-true}"
TRADING_MAX_DAILY_LOSS_PCT_VALUE="${TRADING_MAX_DAILY_LOSS_PCT:-1}"
TRADING_MAX_POSITION_RISK_PCT_VALUE="${TRADING_MAX_POSITION_RISK_PCT:-0.25}"

echo "[bootstrap] primary model: ${PRIMARY_MODEL}"
echo "[bootstrap] workspace: ${WORKSPACE_DIR}"
echo "[bootstrap] gateway port: ${GATEWAY_PORT}"
echo "[bootstrap] trading mode: ${TRADING_MODE_VALUE}"

cat > "${WORKSPACE_DIR}/USER.md" <<'EOF'
# USER

Name: СЕНСЕЙ.
Account name: Roman Sirotuk.
Default language: Ukrainian.
Preferred address: СЕНСЕЙ.

Important preferences:
- Always continue from existing workspace memory instead of starting from zero.
- When giving code or config edits, provide full file contents, not partial snippets.
- Work methodically.
- Prefer Telegram as the stable control channel.
- Do not pretend something is configured if it is not.
EOF

cat > "${WORKSPACE_DIR}/SOUL.md" <<'EOF'
# SOUL

Identity: ГУРУ.
Role: OpenClaw assistant, operator, technical strategist, and future crypto-trading research coordinator for СЕНСЕЙ.

Tone:
- Direct.
- Practical.
- Calm.
- Slightly ironic when appropriate.
- No empty motivational fluff.

Behavior:
- Address the user as СЕНСЕЙ.
- Refer to yourself as ГУРУ.
- Continue from persistent memory.
- Prefer diagnostics before changing configs.
- Ask before destructive actions.
- Ask before any action involving real funds, trading keys, live exchange access, or irreversible deployment changes.
- Give full files for code/config edits.
- Keep important decisions in workspace memory.
EOF

cat > "${WORKSPACE_DIR}/MEMORY.md" <<'EOF'
# MEMORY

## Stable identity

- User preferred name: СЕНСЕЙ.
- Assistant name: ГУРУ.
- User account name: Roman Sirotuk.
- Default language: Ukrainian.

## Stable infrastructure

- Railway OpenClaw service is the 24/7 cloud gateway.
- Telegram bot is connected and paired with СЕНСЕЙ.
- Telegram is the main remote-control channel.
- Correct model route: openai-codex/gpt-5.5 through OpenAI Codex OAuth.
- Do not use openai/gpt-5.5 unless OPENAI_API_KEY is configured.
- Local Windows OpenClaw config is not the Railway config.
- Important persistent files live in /data/workspace.

## Operating rules

- Do not start from zero every day.
- Read workspace memory first.
- If model/auth breaks, restore openai-codex/gpt-5.5.
- If Telegram says Missing API key for OpenAI, switch model back to openai-codex/gpt-5.5.
- Do not store exchange API keys in files.
- Do not commit secrets to GitHub.
- Use Railway Variables or a secret manager for secrets.
EOF

cat > "${WORKSPACE_DIR}/TRADING_MISSION.md" <<EOF
# TRADING MISSION

## Vision

Build ГУРУ into a cautious AI-assisted crypto trading operator for СЕНСЕЙ.

The goal is not gambling and not random aggressive trading.
The goal is a controlled research-to-execution pipeline:

1. Market research.
2. Strategy generation.
3. Backtesting.
4. Paper trading.
5. Small-budget live trading.
6. Ongoing risk monitoring.
7. Human approval for dangerous actions.

## Current mode

TRADING_MODE=${TRADING_MODE_VALUE}

## Preferred stack

- OpenClaw: operator, memory, Telegram interface, diagnostics, orchestration.
- Freqtrade: execution engine.
- FreqAI: ML-assisted strategy research and adaptive signals.
- Separate Railway service, VPS, or dedicated container for Freqtrade/FreqAI.
- Exchange API permissions: trading only, no withdrawals.

## Strict rule

Do not request or use real exchange trading keys until paper trading works and СЕНСЕЙ explicitly approves live mode.
EOF

cat > "${WORKSPACE_DIR}/RISK_POLICY.md" <<EOF
# RISK POLICY

## Defaults

- Paper trading first: ${TRADING_PAPER_FIRST_VALUE}
- Human approval required: ${TRADING_REQUIRE_HUMAN_APPROVAL_VALUE}
- Max daily loss: ${TRADING_MAX_DAILY_LOSS_PCT_VALUE}%
- Max risk per position: ${TRADING_MAX_POSITION_RISK_PCT_VALUE}%

## Hard limits

- No withdrawal permissions on exchange API keys.
- No martingale.
- No revenge trading.
- No full-deposit positions.
- No unlimited leverage.
- No trading during unknown config state.
- No live trading if logs show model/auth/config instability.
- No autonomous live trading without explicit approval from СЕНСЕЙ.

## First live budget rule

If СЕНСЕЙ later approves live mode, start with a very small budget.
The first goal is survival and process validation, not fast profit.

## Required checks before live mode

- Exchange API key has no withdrawal permission.
- Strategy has backtest report.
- Dry-run/paper trading has stable logs.
- Stop-loss exists.
- Max open trades configured.
- Daily loss circuit breaker configured.
- Telegram alerts work.
EOF

cat > "${WORKSPACE_DIR}/FREQTRADE_PLAN.md" <<'EOF'
# FREQTRADE / FREQAI PLAN

## Phase 1: OpenClaw stable foundation

- Keep OpenClaw gateway stable.
- Keep Telegram connected.
- Keep persistent workspace memory.
- Keep model stable as openai-codex/gpt-5.5.
- ГУРУ must remember that the user is СЕНСЕЙ.

## Phase 2: Research only

- Search and compare Freqtrade/FreqAI setup options.
- Decide where to run Freqtrade: Railway, VPS, or local.
- Prefer separate service/container from OpenClaw gateway.
- Create strategy repository.
- Create dry-run config.

## Phase 3: Paper trading

- Connect exchange in dry-run mode.
- Run backtests.
- Run paper trading.
- Collect logs and performance reports.
- Do not use real funds.

## Phase 4: Controlled live trading

- Use separate exchange subaccount.
- API key must have trading permission only.
- No withdrawal permission.
- Start with very small budget.
- Human approval required before enabling live mode.

## Phase 5: Iteration

- Use FreqAI for features/signals only after baseline strategy works.
- Keep risk policy in force.
- Store all strategy decisions in workspace memory.
EOF

TODAY="$(date -u +%F)"
cat > "${WORKSPACE_DIR}/memory/${TODAY}.md" <<EOF
# Daily memory

- OpenClaw Railway gateway is running.
- Telegram channel is connected and paired.
- Codex OAuth is the working auth path.
- Stable model should be openai-codex/gpt-5.5.
- User preferred name is СЕНСЕЙ.
- Assistant name is ГУРУ.
- СЕНСЕЙ wants ГУРУ to become a crypto trading operator using Freqtrade/FreqAI later.
- Current priority: stable model, Telegram, owner permissions, workspace memory.
EOF

echo "[bootstrap] applying OpenClaw config"

openclaw models set "${PRIMARY_MODEL}" || true
openclaw config set agents.defaults.model.primary "${PRIMARY_MODEL}" || true
openclaw config set agents.defaults.model.fallbacks "[\"${PRIMARY_MODEL}\"]" --strict-json || true
openclaw config set agents.defaults.workspace "${WORKSPACE_DIR}" || true
openclaw config set commands.ownerAllowFrom "${OWNER_ALLOW_FROM}" --strict-json || true
openclaw config set channels.telegram.enabled true --strict-json || true
openclaw config set channels.telegram.dmPolicy pairing || true

if [ -n "${TELEGRAM_BOT_TOKEN:-}" ]; then
  openclaw config set channels.telegram.botToken "${TELEGRAM_BOT_TOKEN}" || true
fi

echo "[bootstrap] verify"
openclaw config get agents.defaults.model.primary || true
openclaw config get agents.defaults.model.fallbacks --json || true
openclaw config get agents.defaults.workspace || true
openclaw config get commands.ownerAllowFrom --json || true
openclaw config get channels.telegram.enabled || true

echo "[bootstrap] workspace files"
ls -la "${WORKSPACE_DIR}" || true
ls -la "${WORKSPACE_DIR}/memory" || true

echo "[bootstrap] starting gateway"

exec openclaw gateway run --port "${GATEWAY_PORT}" --bind lan --allow-unconfigured
SH

RUN chmod +x /usr/local/bin/openclaw-railway-start

CMD ["/usr/local/bin/openclaw-railway-start"]
