# Helix Development Cheatsheet

## Setup
1. Ensure devenv is installed: `nix profile install nixpkgs#devenv`
2. Navigate to the dev directory: `cd my-addition/helix-dev/`
3. Clone your Helix fork: `git clone https://github.com/yourusername/helix.git` (replace with your fork URL)

## Entering the Development Environment
- `devenv shell` - Enter the isolated development shell with all tools
- `devenv up` - Start any background services (none currently)
- `exit` - Leave the shell

## Building Helix
- `build` - Build Helix in release mode (`cargo build --release`)
- `run` - Check the built Helix version (`./target/release/hx --version`)
- `test` - Run Helix's test suite (`cargo test`)

## Testing AI Integration
- `test-ai` - Run automated AI setup checks
- Manual test:
  1. Create test file: `echo 'fn main() { }' > test.rs`
  2. Open with custom Helix: `./target/release/hx test.rs`
  3. Type inside `{}` - AI completions should appear
  4. Try `Ctrl+X` for manual trigger
  5. Try `Space+A` for AI code actions

## Development Workflow
1. Make changes to Helix source code
2. `build` to compile
3. `run` to verify it starts
4. `test` to run tests
5. `test-ai` to check AI integration
6. Test manually in the editor

## Key Files
- `devenv.nix` - Development environment configuration
- `helix/` - Your Helix source code (after cloning)
- `test.rs` - Test file for AI features

## Environment Variables
- `HANDLER=copilot` - Set for helix-gpt
- `RUST_BACKTRACE=1` - For better error messages

## Tips
- Use `cargo check` for quick syntax validation
- Use `cargo clippy` for linting
- Logs are in `~/.cache/helix/helix.log` when testing
- Compare with stable Helix: `helix --version` (system package)

## Updating the Environment
- Edit `devenv.nix` to add/remove packages or scripts
- Run `devenv shell` again to apply changes