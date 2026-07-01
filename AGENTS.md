# DevPod Dotfiles - Agent Rules

## Project Overview

This repository contains stow-based dotfiles for DevPod development environments. It provides:
- Shell scripts for devpod setup and management
- OpenCode configuration (agents, skills, commands)
- Nvim, tmux, and other tool configurations

## Repository Structure

```
dotfiles-devpods/
├── install.sh                    # Main installer (stow, git, ssh, gpg, plugins)
├── TESTS.md                      # Comprehensive test suite
├── .devcontainer.json            # DevPod container config
└── targets/
    ├── bin/bin/                  # Utility scripts (stowed to ~/bin)
    │   ├── devpod-setup          # One-time setup orchestrator
    │   ├── devpod-status         # Health check
    │   ├── graphify-project      # Init graphify + git hooks
    │   └── project-init          # Scaffold new project
    ├── nvim/.config/nvim/        # LazyVim config
    ├── opencode/.config/opencode/# OpenCode config
    │   ├── AGENTS.md             # Global agent rules
    │   ├── opencode.json         # Provider/permissions config
    │   ├── tui.json              # TUI settings
    │   ├── agents/explorer.md    # Graph-first exploration agent
    │   ├── skills/               # Git-master, TDD workflow
    │   └── commands/             # git-status, git-review, ulw-loop
    └── tmux/.tmux.conf           # Tmux config with TPM
```

## Key Scripts

### devpod-setup
One-time setup after `devpod up`. Runs install.sh, installs TPM, initializes graphify.
```bash
devpod-setup
```

### devpod-status
Health check for the devpod environment.
```bash
devpod-status
# Shows: SSH, GPG, Git, Nvim, Tmux, OpenCode, Docker
```

### graphify-project
Initialize graphify knowledge graph + git hooks for any project.
```bash
graphify-project        # Build graph + install hooks
graphify-project --force  # Rebuild existing graph
```

### project-init
Scaffold a new project with git, graphify, AGENTS.md.
```bash
project-init my-project
```

## OpenCode Configuration

### Agents
- **explorer** - Graph-first codebase exploration (read-only subagent)

### Skills
- **git-master** - Git expert: commit architect, rebase surgeon, history archaeologist
- **tdd-workflow** - Test-driven development: red-green-refactor cycle

### Commands
- `/git-status` - Quick git state summary
- `/git-review` - Review uncommitted changes
- `/ulw-loop` - Autonomous development loop

## Testing

Run the test suite from TESTS.md:
```bash
# External validation (readonly)
bash -n targets/bin/bin/*

# Internal validation (inside devpod)
devpod-status
devpod-setup
graphify-project
project-init

# Interactive validation (opencode)
/git-status
/git-review
```

## Git Conventions

- Use conventional commits: `feat:`, `fix:`, `refactor:`, `test:`, `docs:`
- Keep commits atomic and focused
- GPG signing enabled (disable with `-c commit.gpgsign=false` if needed)

## Integration

### devpods-builds
- Contains Dockerfile and CI/CD workflow
- Image: `ghcr.io/v1xp-org/devpod-cli-uv:latest`
- Includes: nvim, tmux, opencode, graphify, stow, docker

### devpods-templates
- Deferred (not needed for now)

## Common Tasks

### Adding a new script
1. Create file in `targets/bin/bin/`
2. Make executable: `chmod +x targets/bin/bin/new-script`
3. Test: `bash -n targets/bin/bin/new-script`
4. Commit: `feat: add new-script for X`

### Adding a new opencode skill
1. Create `targets/opencode/.config/opencode/skills/skill-name/SKILL.md`
2. Add frontmatter: name, description, category, risk
3. Write skill content with trigger words and instructions
4. Test in opencode

### Adding a new opencode command
1. Create `targets/opencode/.config/opencode/commands/command-name.md`
2. Add frontmatter: description
3. Write command instructions
4. Test: `/command-name` in opencode

## Troubleshooting

### Scripts not found
```bash
# Ensure ~/bin is in PATH
echo $PATH | grep -q "$HOME/bin" || echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
```

### Stow fails
```bash
# Check symlinks
ls -la ~/bin/ | grep devpod
# Re-stow if needed
cd targets && stow --target=~ -v bin
```

### GPG signing fails
```bash
# Disable if gnupg not available
git config --global commit.gpgsign false
```

### Graphify not installed
```bash
uv tool install graphifyy
```
