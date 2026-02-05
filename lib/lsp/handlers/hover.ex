# SPDX-License-Identifier: PMPL-1.0-or-later
# SPDX-FileCopyrightText: 2025 Jonathan D.A. Jewell <jonathan.jewell@open.ac.uk>

defmodule PolySSG.LSP.Handlers.Hover do
  @moduledoc """
  Provides hover documentation for SSG-specific syntax.

  Shows:
  - Template function documentation
  - Shortcode usage examples
  - Configuration option descriptions
  """

  def handle(_params, _assigns) do
    # TODO: Implement hover logic
    # For now, return nil (no hover info)
    nil
  end

  # Future: Provide context-aware documentation
  # defp get_template_function_docs(function_name) do
  #   # Look up function in SSG documentation database
  # end
end
