;; SPDX-License-Identifier: PMPL-1.0-or-later
;; ECOSYSTEM.scm - Project ecosystem position

(ecosystem
 (version "1.0")
 (name "poly-ssg-lsp")
 (type "tool")
 (purpose "Language Server Protocol implementation for IDE integration of 60+ static site generators")

 (position-in-ecosystem
  "Provides IDE/editor integration layer for the poly-ssg-mcp hub. "
  "While poly-ssg-mcp provides MCP tool integration for AI assistants, "
  "poly-ssg-lsp provides LSP integration for human developers using "
  "editors like VSCode, Neovim, Emacs, etc.")

 (related-projects
  ((dependency "poly-ssg-mcp"
               "Hub for 60+ SSG adapters. poly-ssg-lsp can reuse adapter logic.")
   (sibling "noteg-ssg"
            "Ada/SPARK SSG. One of the 60+ generators supported by this LSP.")
   (consumer "vscode-poly-ssg"
             "VSCode extension using this LSP (planned).")
   (inspiration "elixir-ls"
                "Elixir LSP server. Architecture inspiration for GenLSP usage.")))

 (what-this-is
  "A Language Server Protocol implementation in Elixir that provides IDE features "
  "(auto-completion, diagnostics, hover docs) for static site generators across "
  "60+ languages. Each SSG adapter runs as an isolated BEAM process with automatic "
  "fault recovery via supervision trees.")

 (what-this-is-not
  "This is not a replacement for poly-ssg-mcp (which serves AI assistants). "
  "This is not an SSG itself - it provides tooling for existing SSGs. "
  "This is not a general-purpose Elixir LSP - it's specific to SSG workflows."))
