;; SPDX-License-Identifier: PMPL-1.0-or-later
;; STATE.scm - Current project state

(define state
  '((metadata
     (version "0.1.0")
     (schema-version "1.0")
     (created "2026-02-05")
     (updated "2026-02-05")
     (project "poly-ssg-lsp")
     (repo "hyperpolymath/poly-ssg-lsp"))

    (project-context
     (name "poly-ssg-lsp")
     (tagline "Language Server Protocol for 60+ static site generators")
     (tech-stack ("Elixir" "GenLSP" "BEAM VM")))

    (current-position
     (phase "initialization")
     (overall-completion 15)
     (components
      ("LSP server scaffold" . done)
      ("Adapter behaviour" . done)
      ("Example adapters (Zola, Hakyll, Franklin)" . done)
      ("Completion handler" . stub)
      ("Diagnostics handler" . stub)
      ("Hover handler" . stub))
     (working-features
      ("SSG detection")
      ("Build command execution")
      ("Serve command execution")))

    (route-to-mvp
     (milestones
      ((name "Core LSP Features")
       (status "in-progress")
       (completion 30)
       (items
        ("LSP server scaffold" . done)
        ("Initialize/shutdown handlers" . done)
        ("Basic text synchronization" . todo)
        ("Execute command support" . done)))

      ((name "SSG Adapters")
       (status "in-progress")
       (completion 5)
       (items
        ("Adapter behaviour definition" . done)
        ("Zola adapter" . done)
        ("Hakyll adapter" . done)
        ("Franklin adapter" . done)
        ("Remaining 57 adapters" . todo)))

      ((name "IDE Features")
       (status "not-started")
       (completion 0)
       (items
        ("Template auto-completion" . todo)
        ("Build diagnostics" . todo)
        ("Hover documentation" . todo)
        ("Go-to-definition" . todo)))

      ((name "Testing & Documentation")
       (status "not-started")
       (completion 0)
       (items
        ("Unit tests for adapters" . todo)
        ("Integration tests" . todo)
        ("User documentation" . todo)
        ("VSCode extension" . todo)))))

    (blockers-and-issues
     (critical ())
     (high
      ("GenLSP dependency needs to be added to deps"))
     (medium
      ("Need to handle adapter crashes gracefully"))
     (low
      ("Add logging configuration")))

    (critical-next-actions
     (immediate
      "Add GenLSP and other dependencies to mix.exs"
      "Test basic LSP initialization"
      "Implement template completion handler")
     (this-week
      "Add 10 more SSG adapters"
      "Implement diagnostics from build output"
      "Create VSCode extension scaffold")
     (this-month
      "Complete all 60 adapter implementations"
      "Add comprehensive test suite"
      "Publish to VSCode marketplace"))))
