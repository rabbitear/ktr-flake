# AGENT.md - ktr-flake Development Journal

This document tracks the evolution, architecture, and maintenance of ktr-flake - a personal NixOS configuration managing 4 daily-use systems.

---

## Overview

**Owner:** Jon Bradley (kreator)  
**Location:** Alaska (America/Anchorage timezone)  
**Purpose:** Unified NixOS flake managing 4 machines used daily with seamless machine-to-machine switching  
**Primary Application:** Daily journaling system (formerly vim user, switched to Helix ~1 month ago)  
**NixOS Channel:** nixos-unstable  
**State Version:** 25.05

---

## Machine Inventory

### yoshi
- **AI Acceleration:** CUDA
- **Services:** Ollama, open-webui, searx
- **Role:** Primary AI workstation

### sasha
- **AI Acceleration:** ROCm
- **Services:** Ollama, n8n, chromecast, searx
- **Role:** Multi-purpose AI + automation server

### hacknet
- **Services:** Base system
- **Role:** General purpose machine

### otternode
- **Services:** Base system
- **Role:** General purpose machine

### wendy
- **Services:** Base system
- **Role:** General purpose machine

---

## Core Architecture

### Flake Structure

```
ktr-flake/
├── flake.nix                    # Main flake entry point
├── hosts/                       # Per-host configurations
│   ├── yoshi/
│   ├── sasha/
│   ├── hacknet/
│   ├── otternode/
│   └── wendy/
├── programs+services/           # Shared service modules
│   ├── default.nix             # Base system configuration
│   ├── ollama-cuda.nix         # CUDA-accelerated Ollama
│   ├── ollama-rocm.nix         # ROCm-accelerated Ollama
│   ├── openwebui.nix           # Open WebUI service
│   ├── searx.nix               # Private search engine
│   ├── n8n-sasha.nix           # N8N automation (sasha only)
│   ├── chromecast.nix          # Chromecast support
│   └── sops.nix                # Secrets management
├── users+home/                  # Home-manager configuration
│   ├── default.nix             # Main user config
│   ├── gnome.nix               # GNOME desktop settings
│   ├── mutt.nix                # Email client config
│   └── sync-jrnl.nix           # Journal sync systemd service
├── my-addition/                 # Custom modules & packages
│   ├── journal-module.nix      # Core journaling system
│   ├── printer-module.nix      # File viewer/printer
│   ├── ingest-module.nix       # File ingestion to journal
│   ├── ort.nix                 # OpenRouter CLI tool
│   └── mcpo.nix                # MCP-to-OpenAPI proxy
├── crypt/                       # Encrypted secrets (sops)
└── tips.nix                     # Experimental features & notes
```

### Key Dependencies

- **home-manager:** User environment management
- **sops-nix:** Secrets management (age-based encryption)
- **nix-ai-tools:** crush (AI assistant) & copilot-cli
- **Custom packages:** ort, mcpo

---

## The Journal System

### Philosophy

The journal is the most important application - it's the daily anchor across all machines. The system must be reliable, fast, and seamless.

### Architecture

**Location:** `~/.journal/`  
**Structure:** Git-backed, organized as `YYYY/MM-DD.md`  
**Editor:** Helix with custom configuration  
**Sync:** Systemd timer (every 30 minutes) + manual `j.` command

### Commands

| Alias | Command | Purpose |
|-------|---------|---------|
| `j` | journal | Edit today's journal |
| `j -N` | journal -N | Edit journal from N days ago |
| `j <term>` | journal search | Search journal with ripgrep+fzf |
| `j.` | commit & push | Commit and push journal to git remote |
| `p` | printer | View today's journal or specified file |
| `p -N` | printer -N | View journal from N days ago |
| `i <file>` | ingest | Ingest file into journal with auto-linking |

### Helix Configuration (Journaling Mode)

**Theme:** `focus_nova` (optimized for prose)  
**Features:**
- Auto-pairs disabled for natural writing
- 72-column text width with rulers
- Soft-wrap enabled
- Absolute line numbers
- Atomic save (always on)
- `space+r` for text reflow
- `space+w` for quick save

### Sync System

**Service:** `systemd.user.services.journal-sync`  
**Timer:** Runs 1 minute after boot, then every 30 minutes  
**Behavior:**
- Auto-commits local changes
- Pulls with `--ff-only` (safe pull)
- Prevents data loss on machine switches

### Current Limitations

- `remoterepository` option set to empty string (needs configuration)
- No pre-sync conflict detection
- Manual `j.` required for immediate sync

---

## Daily Workflow

At any time, with any thought, grab a keyboard open a terminal and type j, to start editing todays jouranl.  Write anything and everything that is on your mind.  Save it and move on to other things.

### Quick Reference Menu

Type `m` for the menu:
```
-==>> ktr's MENU -==>>
  j - journal <search>  j. to commit
 i - injest <file>     b build $(hostname)
p - print <file>
```

### Build & Deploy

The `b` alias handles system rebuilds:
1. Detects if in `ktr-flake` directory
2. Runs `nixos-rebuild switch --flake .#$(hostname)`
3. On success: auto-commits with timestamp
4. Reminds to reload `~/.bashrc`

**Philosophy:** Rapid iteration with automatic git history

### File Operations

**Printer (p):** Intelligent MIME-type detection
- Images → imv
- PDFs → zathura
- Text/code → bat with syntax highlighting
- Media → mpv
- Journal entries → bat with line numbers

**Ingest (i):** Copy file to journal
- Detects MIME type
- Creates `~/.journal/<type>/` hierarchy
- Prefixes with Unix epoch timestamp
- Sanitizes filenames (spaces → underscores)
- Creates markdown link in today's journal
- Auto-commits to git

---

## Development Environment

### Helix (Main Editor)

**Theme:** `ayu_evolve`  
**Line Numbers:** Relative  
**Key Bindings:**
- `space+space` → file picker
- `space+w` → save
- `space+q` → quit
- `esc` → collapse selection

### Terminal Setup

**Primary:** foot terminal (Super+Return)  
**Dropdown:** ddterm (Alt+Space)  
**Font:** M PLUS 1 Code, size 20  
**Color Scheme:** Tokyo Night

### Shell (Bash)

**Vi mode:** Enabled  
**Prompt:** Starship  
**Tools:**
- fzf for fuzzy finding
- yazi for file browsing
- nix-search-tv for package search
- bat for syntax highlighting
- ripgrep for fast search

### Development Shells

**Default:** Rust development (ort)
- rustc, cargo, clang, pkg-config
- openssl, zlib

**crushpython:** Python development
- Python 3 with numpy, pandas, jupyter
- uv for package management
- Auto-installs dspy-ai

---

## GNOME Desktop Configuration

### Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| Super+Return | Open foot terminal |
| Alt+Space | Toggle ddterm |
| Super+Q | Close window |
| Super+F | Toggle fullscreen |
| Super+Y | Flameshot screenshot |
| Super+Z | Magnifier |
| Ctrl+1-4 | Switch to workspace 1-4 |
| Ctrl+Shift+1-4 | Move window to workspace 1-4 |

### Extensions

- no-overview: Disable Activities overview
- ddterm: Dropdown terminal
- appindicator: System tray support

### Workspace Setup

- 4 static workspaces (non-dynamic)
- Dark mode preferred
- Green accent color
- Custom wallpapers (light/dark variants)

---

## AI & LLM Infrastructure

### Local Models (Ollama)

**yoshi (CUDA):**
- llama3.2:3b
- deepseek-r1:1.5b

**sasha (ROCm):**
- deepseek-r1:1.5b

**Network:** Open on 0.0.0.0 (accessible via Tailscale)

### OpenRouter Integration

**Tool:** ort (custom Rust CLI)  
**Config:** `~/.config/ort.json`  
**Model:** tngtech/deepseek-r1t2-chimera:free  
**Settings:**
- Save to file: enabled
- Custom DNS: Cloudflare
- Reasoning: medium effort
- Priority: price
- System prompt: "Concise but complete. No yapping. Direct professional tone."

### MCP (Model Context Protocol)

**Tool:** mcpo (MCP-to-OpenAPI proxy)  
**Port:** 3003  
**Features:**
- Hot-reload config support
- Multiple MCP servers
- Integrated with open-webui

### Open WebUI

**Port:** 3002  
**Access:** 0.0.0.0 (Tailscale network)  
**Integration:** Connected to local Ollama

### Private Search

**Engine:** SearXNG  
**Port:** 3001  
**Features:**
- Vim keybindings
- Dark theme
- DuckDuckGo autocomplete
- Multiple image/video sources
- Privacy-focused (no tracking)

### W3M Integration

**Alias:** `?` for DuckDuckGo searches  
**Editor:** Helix  
**Usage:** `? <search terms>` opens w3m in lite mode

---

## Security & Networking

### Secrets Management (sops-nix)

**Method:** age encryption  
**Key Location:** `~/.config/sops/age/keys.txt`  
**Secrets:**
- kreator user password
- GitHub SSH key (theshack)
- OpenRouter API key
- Hugging Face API key
- Mutt email credentials

### SSH Configuration

**GitHub:** Uses `~/.ssh/theshack` identity  
**Authorized Keys:** theshack public key on all hosts

### Tailscale

**Mode:** Userspace networking  
**Interface:** tailscale0 (trusted)  
**Services Exposed:** SSH (22), searx (3001), open-webui (3002)

### Firewall

**Trusted:** Tailscale network, local network  
**fail2ban:** Enabled (3 retry max, progressive ban)  
**Ignored IPs:**
- 127.0.0.1/8 (localhost)
- 10.0.0.174 (local network)
- 100.67.201.23 (Tailscale)

---

## Custom Packages & Tools

### ort (OpenRouter CLI)

**Source:** github:grahamking/ort  
**Language:** Rust  
**Purpose:** Honest OpenRouter client  
**Build:** Custom Nix derivation (tests disabled)

### mcpo (MCP-to-OpenAPI Proxy)

**Source:** github:open-webui/mcpo  
**Language:** Python  
**Purpose:** Bridge MCP servers to OpenAPI  
**Custom:** Includes packaged MCP Python SDK  
**Features:**
- Multiple server support via config.json
- Hot-reload configuration
- Authentication support
- Path for Node.js/Python/Nix tools

---

## Known Issues & TODOs

### Current Build Issue (2025-11-07)

**Problem:** `python3.13-rapidocr-onnxruntime-1.4.4` test failure  
**Error:** Exit code 134 (SIGABRT) during pytest  
**Impact:** Blocks open-webui package build on yoshi  
**Fix Applied:** Updated `openwebui.nix` to use `nixpkgs.overlays` instead of `nixpkgs.config.packageOverrides`  
**Status:** Pending rebuild verification

### TODOs

- [ ] Configure journal `remoterepository` option for proper git sync
- [ ] Add `nix flake check` to `b` alias before rebuild
- [ ] Add pre-commit hook to verify builds
- [ ] Clean up commented code in `tips.nix`
- [ ] Fix searx dependency on non-existent home files
- [ ] Implement journal conflict detection before sync
- [ ] Document MCP server configuration examples
- [ ] Add journal backup strategy
- [ ] Consider journal encryption for sensitive entries
- [ ] Document n8n workflows on sasha

---

## Learning & Development Notes

### Nix Strengths Demonstrated

- Clean separation of concerns (hosts/services/users)
- Custom module creation with proper option interfaces
- Multi-language package building (Rust, Python)
- Overlay system for package customization
- Home-manager integration
- Secrets management

### Areas for Growth

- Flake inputs management
- Custom NixOS modules (more advanced)
- Cross-compilation
- Binary cache setup
- Hydra CI/CD integration

---

## Development History

### 2025-11-07
- **Agent Analysis:** Complete flake analysis and documentation
- **Created:** This AGENT.md file for ongoing development tracking
- **Fixed:** openwebui.nix overlay configuration for rapidocr-onnxruntime

### 2025-11-06
- Multiple successful builds throughout the day
- Iterating on journal and printer functionality
- Git syntax corrections in sync scripts

### 2025-11-05
- Multiple boot configuration fixes
- Testing and refinement

### 2025-11-04
- Journal sync timer implementation
- Print journal file by -N days feature
- Git workflow improvements

### Recent
- Switched from vim to Helix editor (~1 month ago)
- Built custom journal system with Helix integration
- Implemented systemd timer for journal sync

---

## Future Directions

### Short Term
1. Verify rapidocr-onnxruntime fix works
2. Configure journal remote repository
3. Add build verification to workflow
4. Document MCP server configs

### Medium Term
1. Explore more MCP integrations
2. Enhance journal search capabilities
3. Build more custom tools in Rust
4. Optimize build times with binary cache

### Long Term
1. Consider declarative journal configuration
2. Integrate more AI tools into workflow
3. Explore NixOS modules for sharing
4. Build knowledge base on top of journal system

---

## Notes for Future Sessions

### When Starting a Session
1. Check current branch: `git branch`
2. Check build status: `b` (if in ktr-flake)
3. Check journal: `j` or `p`
4. Review recent history: `git log --oneline -10`

### When Making Changes
1. Test on one host first (probably yoshi)
2. Commit successful builds automatically via `b`
3. Sync journal if working on journal-related changes
4. Document significant changes in this file

### Key Files to Review
- `flake.nix` - Overall structure
- `programs+services/default.nix` - Base system
- `users+home/default.nix` - User environment
- `my-addition/journal-module.nix` - Journal core

---

## Questions & Explorations

### Open Questions
- Should journal support multiple branches for different topics?
- How to handle journal merge conflicts better?
- Best practice for secrets in journal (currently avoid sensitive data)?
- Should build automation be more conservative?

### Experiments to Try
- NixOS modules for sharing journal system
- Custom search engine integration with journal
- AI-assisted journal analysis
- Cross-host journal statistics
- Automated journal backups to S3/B2

---

*This document is maintained by kreator with assistance from AI agents.  
Last updated: 2025-11-07*
