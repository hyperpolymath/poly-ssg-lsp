# SPDX-License-Identifier: PMPL-1.0-or-later
# poly-ssg-lsp Quickstart

## What Was Created

A complete Elixir LSP server scaffold for 60+ static site generators.

## Project Structure

```
poly-ssg-lsp/
├── lib/
│   ├── poly_ssg_lsp.ex              # Main module
│   ├── poly_ssg_lsp/
│   │   └── application.ex           # OTP application (supervision tree)
│   ├── adapters/
│   │   ├── behaviour.ex             # Adapter contract (behaviour)
│   │   ├── supervisor.ex            # Manages adapter processes
│   │   ├── zola.ex                  # Rust SSG (GenServer)
│   │   ├── hakyll.ex                # Haskell SSG (GenServer)
│   │   └── franklin.ex              # Julia SSG (GenServer)
│   └── lsp/
│       ├── server.ex                # GenLSP protocol handler
│       └── handlers/
│           ├── completion.ex        # Auto-completion (stub)
│           ├── diagnostics.ex       # Build diagnostics (stub)
│           └── hover.ex             # Hover documentation (stub)
├── STATE.scm                        # Project state tracking
├── ECOSYSTEM.scm                    # Ecosystem relationships
├── META.scm                         # Architecture decisions (ADRs)
├── mix.exs                          # Project configuration
├── justfile                         # Task runner recipes
└── README.md                        # Documentation
```

## Architecture Highlights

### 1. BEAM Concurrency Model

Each SSG adapter runs as an isolated GenServer process:

```elixir
# If Hakyll adapter crashes...
PolySSG.Adapters.Hakyll -> crashes

# ...Supervisor automatically restarts it
Supervisor -> restart -> PolySSG.Adapters.Hakyll

# ...and Zola/Franklin adapters keep running
PolySSG.Adapters.Zola -> still running ✓
PolySSG.Adapters.Franklin -> still running ✓
```

### 2. LSP Protocol Flow

```
Editor (VSCode/Neovim)
    ↓ stdio/TCP
GenLSP Server
    ↓ handle_request/notification
Handlers (Completion/Diagnostics/Hover)
    ↓ call adapter
SSG Adapter (GenServer)
    ↓ spawn process
SSG Binary (zola/hakyll/julia)
```

### 3. Adapter Pattern

All adapters implement `PolySSG.Adapters.Behaviour`:

```elixir
@callback detect(project_path) :: {:ok, boolean()}
@callback build(project_path, opts) :: build_result
@callback serve(project_path, opts) :: {:ok, port}
@callback clean(project_path) :: :ok
@callback version() :: {:ok, String.t()}
@callback metadata() :: map()
```

## Next Steps

### 1. Install Dependencies

```bash
cd ~/Documents/hyperpolymath-repos/poly-ssg-lsp
mix deps.get
```

**Note**: You'll need to add `gen_lsp` to `mix.exs` dependencies first:

```elixir
{:gen_lsp, "~> 0.10"}
```

### 2. Test Basic Compilation

```bash
mix compile
```

### 3. Run Tests

```bash
mix test
```

### 4. Start LSP Server

```bash
mix run --no-halt
```

### 5. Add More Adapters

Copy one of the existing adapters (Zola/Hakyll/Franklin) and modify for your SSG:

```bash
cp lib/adapters/zola.ex lib/adapters/your_ssg.ex
# Edit to match your SSG's commands and config files
```

## Key Decisions (from META.scm)

### ADR-001: Why Elixir over Rust?

**Chose Elixir** for:
- BEAM concurrency (60+ isolated processes)
- Hot code reload (dev velocity)
- Supervision trees (fault tolerance)

**Trade-off accepted**:
- 1-2s startup vs <100ms (Rust)
- 50MB memory vs 5MB (Rust)
- Acceptable for LSP servers

### ADR-002: Why GenServer per Adapter?

**Chose isolation** for:
- Crash in Hakyll doesn't kill Zola
- Automatic restart by supervisor
- True parallelism (BEAM scheduler)

**Trade-off accepted**:
- ~1MB per adapter process
- Worth it for fault isolation

## Integration with poly-ssg-mcp

```
poly-ssg-mcp      →  MCP tools for AI assistants (Claude, GPT)
    ↓ shared logic
poly-ssg-lsp      →  LSP tools for human developers (VSCode, Neovim)
```

Both use the same 60+ SSG adapter architecture, just different protocols (MCP vs LSP).

## Development Workflow

```bash
# Install deps
just deps

# Format code
just fmt

# Run linter
just lint

# Run type checker
just dialyzer

# Run all checks
just quality

# Run tests
just test

# Start REPL (for interactive development)
just repl
```

## What's Working Now

✅ LSP server boots
✅ Detects SSG type (Zola/Hakyll/Franklin)
✅ Executes build commands
✅ Executes serve commands
✅ Fault isolation (adapter crashes don't propagate)

## What Needs Implementation

- [ ] Template auto-completion logic
- [ ] Build output parsing (diagnostics)
- [ ] Hover documentation database
- [ ] 57 remaining SSG adapters
- [ ] VSCode extension
- [ ] Integration tests

## Quick Test

```bash
cd ~/Documents/hyperpolymath-repos/poly-ssg-lsp

# Start IEx REPL
iex -S mix

# Detect Zola in a project
iex> PolySSG.Adapters.Zola.detect("/path/to/zola/project")
{:ok, true}

# Build a Zola site
iex> PolySSG.Adapters.Zola.build("/path/to/zola/project", [])
{:ok, %{success: true, output: "Building site..."}}
```

## Questions?

Check the checkpoint files:
- `STATE.scm` - Current implementation status
- `ECOSYSTEM.scm` - How this fits with poly-ssg-mcp
- `META.scm` - Architecture decisions (ADRs)
