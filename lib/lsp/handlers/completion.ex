# SPDX-License-Identifier: PMPL-1.0-or-later
# SPDX-FileCopyrightText: 2025 Jonathan D.A. Jewell <jonathan.jewell@open.ac.uk>

defmodule PolySSG.LSP.Handlers.Completion do
  @moduledoc """
  Provides auto-completion for SSG templates and configuration.

  Supports:
  - Template syntax (Tera, Liquid, Jinja)
  - Frontmatter fields
  - Shortcodes
  - Configuration keys
  """

  def handle(_params, _assigns) do
    # TODO: Implement completion logic
    # For now, return empty completion list
    []
  end

  # Future: Parse template files and provide context-aware completions
  # defp complete_template_syntax(position, content) do
  #   # Detect {{ | {% and provide completions
  # end
end
