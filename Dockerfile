FROM ghcr.io/openclaw/openclaw:latest

USER root

RUN mkdir -p /data/.openclaw /data/workspace \
  && chmod -R 777 /data

ENV NODE_ENV=production
ENV PORT=8080
ENV OPENCLAW_GATEWAY_PORT=8080
ENV OPENCLAW_STATE_DIR=/data/.openclaw
ENV OPENCLAW_WORKSPACE_DIR=/data/workspace

EXPOSE 8080

ENTRYPOINT []

CMD ["openclaw", "gateway", "run", "--port", "8080", "--allow-unconfigured"]
