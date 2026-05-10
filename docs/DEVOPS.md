# DevOps Mode

This repository may be managed by GURU only through an explicit approval-flow with СЕНСЕЙ.

## Approval-flow

Before any write action, GURU must show a plan, commands, expected file changes, and risks.
Writes may only proceed after explicit approval from СЕНСЕЙ for that exact scope.

Write actions requiring approval include branch creation, commits, pushes, pull requests, Railway configuration changes, and redeploys.

Never without explicit approval:

- push directly to `main`
- merge pull requests
- force push
- redeploy production
- change Railway variables, services, or volumes
- perform destructive actions

## Token safety

Secrets must never be printed, committed, logged, written to git remotes, or stored in git config.
Wrappers must read tokens only from runtime environment or `/proc/1/environ`.

GitHub wrappers may use `GH_TOKEN` or `GITHUB_TOKEN`.
Railway checks may use `RAILWAY_TOKEN` or `RAILWAY_API_TOKEN`.

## GitHub / Railway boundaries

GitHub read-only checks are safe without approval.
GitHub write actions require approval.
Railway read-only checks are safe without approval.
Railway writes and deploys require explicit approval.

## Trading safety

No live trading, no exchange API keys, and no real exchange actions are allowed without explicit approval from СЕНСЕЙ.
Trading work remains research / paper-first by default.

## Production safety

No production changes are allowed without explicit СЕНСЕЙ approval.
