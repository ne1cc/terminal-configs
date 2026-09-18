---
name: github-namespace
description: Manage local repos with the ~/Github/<owner> namespace pattern and gnn/gnp/gns/gmc/gnc/gnf shortcuts for ne1cc.
---

# GitHub namespace workflow

Primary GitHub user/org: **ne1cc**.

## Layout
- Synced remotes: `~/Github/ne1cc/<repo>`
- Local WIP (no remote): `~/Github/_local/projects/<name>`
- Archive / worktrees: `~/Github/_local/archive`, `~/Github/_local/worktrees`
- Synced owners file: `~/Github/.mirror-owners`

## Commands
- `gnn <name> [--python|--node]` — create local WIP project
- `gnp [--public] [--name X] [--owner ne1cc]` — promote local → GitHub + move into `~/Github/ne1cc/`
- `gns` — local WIP + mirror status
- `gmc` — mirror drift (`MISSING` / `ORPHAN`)
- `gnc owner/repo` — clone into `~/Github/<owner>/<repo>`
- `gnf owner/repo` — fork then clone under your account; set upstream

## Agent rules
- Do not use flat `~/Github/<repo>` for ne1cc remotes.
- Publish with `gnp`, not ad-hoc `gh repo create` + leave folder in `_local`.
- Never put third-party orgs in `.mirror-owners`.
- Ignore secrets and heavy artifacts before first push.
