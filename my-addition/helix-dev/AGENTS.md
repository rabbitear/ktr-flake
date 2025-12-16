# AI Agents and Tools for Helix Development

This document outlines the AI tools and integrations available for this Helix fork project.

## Current AI Integrations

### 1. Helix-GPT (Existing)
- **Purpose**: AI-powered code completions
- **Handler**: Copilot
- **Setup**: Already configured in devenv.nix
- **Usage**: Provides intelligent code suggestions during editing

### 2. Ollama Integration (New)
- **Purpose**: Local LLM text generation via commands
- **Implementation**: `:ai-generate` command in Helix
- **API**: Calls Ollama REST API at http://sasha:11434
- **Model**: Currently hardcoded to devstral-small-2:24b (configurable in future)
- **Usage**: `:ai-generate <prompt>` - generates text and inserts at cursor
- **Status**: Implemented and compiled successfully

## Development Environment

### Devenv Configuration
- Located in `devenv.nix`
- Includes Rust toolchain, OpenSSL dev, and helix-gpt
- Scripts available:
  - `build`: Compile Helix
  - `run`: Test compiled Helix
  - `test-ai`: Check AI setup

### Building
```bash
# Set PKG_CONFIG_PATH for OpenSSL
export PKG_CONFIG_PATH=/nix/store/.../lib/pkgconfig:$PKG_CONFIG_PATH
cd helix && cargo build --release
```

## Future AI Features to Explore

1. **Configurable Models**: Allow users to specify different Ollama models
2. **Code Completion**: Integrate Ollama for context-aware completions
3. **Refactoring Suggestions**: AI-powered code refactoring commands
4. **Documentation Generation**: Auto-generate doc comments
5. **Error Explanation**: Explain compiler errors using AI
6. **Multi-Model Support**: Support for other LLM providers (OpenAI, Anthropic, etc.)

## Testing AI Features

1. **Ollama Setup**:
   ```bash
   # Install Ollama
   # Pull a model
   ollama pull llama3.2
   # Start Ollama server
   ollama serve
   ```

2. **Test Commands**:
   - `:ai-generate Write a hello world function in Rust`
   - Check that text is inserted at cursor
   - Use `custom-hx` alias to run the modified Helix
   - Command-line usage: `hx --command "ai-generate hello world" file.txt`

## Notes

- Current implementation uses blocking HTTP requests (synchronous)
- Error handling is basic - shows errors in status bar
- Model selection is hardcoded - should be made configurable
- No caching or request deduplication yet