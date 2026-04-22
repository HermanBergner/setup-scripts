# Feature 001 — Export

## What it does

`export/export.sh` snapshots the current Arch Linux WSL environment into two committed artifacts:

1. `manifest/packages.json` — a JSON record of every explicitly installed package (pacman and AUR), with a UTC timestamp.
2. `scripts/install-packages.sh` — a generated, ready-to-run bash script that re-installs all packages on a new machine.

Running export on your existing machine, then committing the output, is the first step before bootstrapping any new WSL instance.

## Prerequisites

| Tool | Purpose |
|------|---------|
| `pacman` | Query explicitly installed packages |
| `yay` | Query AUR packages |
| `jq` | Build and format the JSON manifest |

All three must be on `PATH`. The script checks for them and exits with a clear message if any are missing.

## Usage

```bash
bash export/export.sh
git add manifest/ scripts/
git commit -m "export: update package manifest"
git push
```

Run from any directory — the script locates itself via `${BASH_SOURCE[0]}`.

## Outputs

| File | Description |
|------|-------------|
| `manifest/packages.json` | JSON snapshot of all packages |
| `scripts/install-packages.sh` | Generated install script |

### manifest/packages.json format

```json
{
  "generated_at": "2026-04-22T10:00:00Z",
  "pacman": ["git", "neovim", "zsh"],
  "aur": ["yay-bin"]
}
```

- `generated_at`: UTC ISO 8601 timestamp
- `pacman`: explicitly installed packages (`pacman -Qe`), sorted alphabetically
- `aur`: AUR packages not in any sync database (`yay -Qm`), sorted alphabetically

## Idempotency

Running export multiple times is safe — each run overwrites the previous `packages.json` and `install-packages.sh`. Git history serves as the version archive.

## Decisions

| Decision | Choice |
|----------|--------|
| AUR helper | `yay` |
| Manifest versioning | Overwrite; git history archives old versions |
| Package query | `pacman -Qe` (explicit only, not dependencies) |
