# SPDX-License-Identifier: PMPL-1.0-or-later
# SPDX-FileCopyrightText: 2025 Jonathan D.A. Jewell <jonathan.jewell@open.ac.uk>

defmodule PolySSG.LSP.Server do
  @moduledoc """
  GenLSP server implementation for PolySSG.

  Handles LSP protocol messages and delegates to appropriate handlers.
  """
  use GenLSP

  require Logger

  alias PolySSG.LSP.Handlers.{Completion, Diagnostics, Hover}

  def start_link(args) do
    GenLSP.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl GenLSP
  def init(lsp, _args) do
    {:ok, assign(lsp, project_path: nil, detected_ssg: nil)}
  end

  @impl GenLSP
  def handle_request(%{"method" => "initialize", "params" => params}, lsp) do
    project_path = get_in(params, ["rootUri"]) |> parse_uri()

    Logger.info("Initializing LSP for project: #{inspect(project_path)}")

    # Auto-detect SSG type
    detected_ssg = detect_ssg(project_path)

    Logger.info("Detected SSG: #{inspect(detected_ssg)}")

    server_capabilities = %{
      "textDocumentSync" => %{
        "openClose" => true,
        "change" => 1,  # Full sync
        "save" => %{"includeText" => false}
      },
      "completionProvider" => %{
        "triggerCharacters" => ["{", "@", "#"],
        "resolveProvider" => false
      },
      "hoverProvider" => true,
      "executeCommandProvider" => %{
        "commands" => ["poly-ssg.build", "poly-ssg.serve", "poly-ssg.clean"]
      }
    }

    result = %{
      "capabilities" => server_capabilities,
      "serverInfo" => %{
        "name" => "PolySSG LSP",
        "version" => PolySSG.LSP.version()
      }
    }

    {:reply, result, assign(lsp, project_path: project_path, detected_ssg: detected_ssg)}
  end

  @impl GenLSP
  def handle_request(%{"method" => "textDocument/completion", "params" => params}, lsp) do
    completions = Completion.handle(params, lsp.assigns)
    {:reply, completions, lsp}
  end

  @impl GenLSP
  def handle_request(%{"method" => "textDocument/hover", "params" => params}, lsp) do
    hover_info = Hover.handle(params, lsp.assigns)
    {:reply, hover_info, lsp}
  end

  @impl GenLSP
  def handle_request(%{"method" => "workspace/executeCommand", "params" => params}, lsp) do
    command = params["command"]
    args = params["arguments"] || []
    result = execute_command(command, args, lsp.assigns)
    {:reply, result, lsp}
  end

  @impl GenLSP
  def handle_request(_request, lsp) do
    {:reply, nil, lsp}
  end

  @impl GenLSP
  def handle_notification(%{"method" => "initialized"}, lsp) do
    Logger.info("LSP server initialized")
    {:noreply, lsp}
  end

  @impl GenLSP
  def handle_notification(%{"method" => "textDocument/didSave", "params" => params}, lsp) do
    uri = params["textDocument"]["uri"]
    Logger.info("File saved: #{uri}")

    # Trigger diagnostics on save
    spawn(fn ->
      diagnostics = Diagnostics.handle(params, lsp.assigns)

      GenLSP.notify(lsp, %{
        "method" => "textDocument/publishDiagnostics",
        "params" => diagnostics
      })
    end)

    {:noreply, lsp}
  end

  @impl GenLSP
  def handle_notification(_notification, lsp), do: {:noreply, lsp}

  # Private helpers

  defp parse_uri(nil), do: nil
  defp parse_uri(uri) when is_binary(uri) do
    case URI.parse(uri) do
      %URI{scheme: "file", path: path} -> path
      _ -> nil
    end
  end

  defp detect_ssg(nil), do: nil
  defp detect_ssg(project_path) do
    adapters = [
      {PolySSG.Adapters.Zola, :zola},
      {PolySSG.Adapters.Hakyll, :hakyll},
      {PolySSG.Adapters.Franklin, :franklin}
    ]

    Enum.find_value(adapters, fn {adapter, name} ->
      case adapter.detect(project_path) do
        {:ok, true} -> name
        _ -> nil
      end
    end)
  end

  defp execute_command("poly-ssg.build", _args, %{project_path: path, detected_ssg: ssg}) when path != nil do
    case ssg do
      :zola -> PolySSG.Adapters.Zola.build(path, [])
      :hakyll -> PolySSG.Adapters.Hakyll.build(path, [])
      :franklin -> PolySSG.Adapters.Franklin.build(path, [])
      _ -> {:error, "No SSG detected"}
    end
  end

  defp execute_command("poly-ssg.serve", _args, %{project_path: path, detected_ssg: ssg}) when path != nil do
    case ssg do
      :zola -> PolySSG.Adapters.Zola.serve(path, [])
      :hakyll -> PolySSG.Adapters.Hakyll.serve(path, [])
      :franklin -> PolySSG.Adapters.Franklin.serve(path, [])
      _ -> {:error, "No SSG detected"}
    end
  end

  defp execute_command("poly-ssg.clean", _args, %{project_path: path, detected_ssg: ssg}) when path != nil do
    case ssg do
      :zola -> PolySSG.Adapters.Zola.clean(path)
      :hakyll -> PolySSG.Adapters.Hakyll.clean(path)
      :franklin -> PolySSG.Adapters.Franklin.clean(path)
      _ -> {:error, "No SSG detected"}
    end
  end

  defp execute_command(_command, _args, _assigns) do
    {:error, "Unknown command or no project detected"}
  end
end
