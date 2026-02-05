;; SPDX-License-Identifier: PMPL-1.0-or-later
;; META.scm - Meta-level project information

(define meta
  '((architecture-decisions
     ((adr-001
       (status "accepted")
       (date "2026-02-05")
       (context "Need to choose implementation language for LSP server")
       (decision "Use Elixir with GenLSP framework instead of Rust")
       (consequences
        "Pros: BEAM concurrency model perfect for 60+ isolated adapter processes. "
        "Hot code reload for fast development. Supervision trees for fault isolation. "
        "Cons: 1-2s startup time vs <100ms for Rust. 50MB memory vs 5MB for Rust. "
        "Trade-off accepted: startup time and memory overhead are acceptable for LSP servers."))

      (adr-002
       (status "accepted")
       (date "2026-02-05")
       (context "Each SSG adapter could share a single process or run independently")
       (decision "Each adapter runs as its own GenServer under a supervision tree")
       (consequences
        "Crash in one adapter (e.g., Hakyll) doesn't affect others (e.g., Zola). "
        "Supervisor automatically restarts crashed adapters. "
        "Trade-off: Higher memory usage (~1MB per adapter) but better fault isolation."))

      (adr-003
       (status "accepted")
       (date "2026-02-05")
       (context "Could implement all adapters upfront or start with subset")
       (decision "Start with 3 reference implementations (Zola, Hakyll, Franklin)")
       (consequences
        "Proves architecture works with diverse SSGs (Rust, Haskell, Julia). "
        "Remaining 57 adapters follow the same pattern. "
        "MVP can be delivered faster with proven adapter interface."))))

    (development-practices
     (code-style
      "Follow Elixir community conventions. "
      "Use Credo for linting. "
      "Dialyzer for type checking. "
      "Format with mix format.")

     (security
      "SPDX headers on all files. "
      "No hardcoded credentials. "
      "Validate all file paths. "
      "Sanitize SSG command arguments.")

     (testing
      "ExUnit for unit tests. "
      "Integration tests for LSP protocol. "
      "Mock SSG binaries for CI. "
      "Property-based tests for adapters.")

     (versioning
      "Semantic versioning. "
      "Changelog in CHANGELOG.md. "
      "Git tags for releases.")

     (documentation
      "ExDoc for API documentation. "
      "README.md for overview. "
      "Inline @moduledoc and @doc. "
      "Examples in doctests.")

     (branching
      "Main branch protected. "
      "Feature branches for new work. "
      "PRs required for merges. "
      "CI checks must pass."))))
