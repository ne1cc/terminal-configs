---
name: github-namespace
description: Manage local repos with the ~/Github/<owner> namespace pattern and gnn/gnp/gns/gmc/gnc/gnf shortcuts for n1ecC.
---

# GitHub namespace workflow

Primary GitHub user/org: **n1ecC**.

## Layout
- Synced remotes: `~/Github/n1ecC/<repo>`
- Local WIP (no remote): `~/Github/_local/projects/<name>`
- Archive / worktrees: `~/Github/_local/archive`, `~/Github/_local/worktrees`
- Synced owners file: `~/Github/.mirror-owners`

## Commands
- `gnn <name> [--python|--node]` — create local WIP project
- `gnp [--public] [--name X] [--owner n1ecC]` — promote local → GitHub + move into `~/Github/n1ecC/`
- `gns` — local WIP + mirror status
- `gmc` — mirror drift (`MISSING` / `ORPHAN`)
- `gnc owner/repo` — clone into `~/Github/<owner>/<repo>`
- `gnf owner/repo` — fork then clone under your account; set upstream

## Agent rules
- Do not use flat `~/Github/<repo>` for n1ecC remotes.
- Publish with `gnp`, not ad-hoc `gh repo create` + leave folder in `_local`.
- Never put third-party orgs in `.mirror-owners`.
- Ignore secrets and heavy artifacts before first push.
