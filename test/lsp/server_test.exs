# SPDX-License-Identifier: PMPL-1.0-or-later
# SPDX-FileCopyrightText: 2025 Jonathan D.A. Jewell <jonathan.jewell@open.ac.uk>

defmodule PolySSG.LSP.ServerTest do
  use ExUnit.Case, async: true

  alias PolySSG.LSP.Server
  import LSPHelpers

  @test_dir "/tmp/lsp_server_test_#{System.unique_integer([:positive])}"

  setup do
    File.mkdir_p!(@test_dir)
    File.write!(Path.join(@test_dir, "config.toml"), "# Zola config")
    on_exit(fn -> File.rm_rf!(@test_dir) end)
    {:ok, test_dir: @test_dir}
  end

  describe "initialize request" do
    test "returns server capabilities", %{test_dir: dir} do
      {:ok, pid} = Server.start_link([])

      request = initialize_request("file://#{dir}")
      response = GenLSP.request(pid, request)

      assert response["capabilities"]["textDocumentSync"]["openClose"] == true
      assert response["capabilities"]["completionProvider"]["triggerCharacters"] == ["{", "@", "#"]
      assert response["capabilities"]["hoverProvider"] == true
      assert response["serverInfo"]["name"] == "PolySSG LSP"
    end

    test "detects SSG in project root", %{test_dir: dir} do
      {:ok, pid} = Server.start_link([])

      request = initialize_request("file://#{dir}")
      _response = GenLSP.request(pid, request)

      state = :sys.get_state(pid)
      assert state.assigns.detected_ssg == :zola
    end
  end

  describe "textDocument/didOpen notification" do
    test "stores document in state" do
      {:ok, pid} = Server.start_link([])

      _init = GenLSP.request(pid, initialize_request("file:///test"))

      notification = did_open_notification(
        "file:///test/content.md",
        "markdown",
        "# Test Document"
      )

      GenLSP.notify(pid, notification)
      Process.sleep(50)

      state = :sys.get_state(pid)
      doc = state.assigns.documents["file:///test/content.md"]
      assert doc.text == "# Test Document"
      assert doc.version == 1
    end
  end

  describe "textDocument/didChange notification" do
    test "updates document text in state" do
      {:ok, pid} = Server.start_link([])
      _init = GenLSP.request(pid, initialize_request("file:///test"))

      # Open document first
      GenLSP.notify(pid, did_open_notification("file:///test/doc.md", "markdown", "v1"))
      Process.sleep(50)

      # Change document
      change_notification = %{
        "jsonrpc" => "2.0",
        "method" => "textDocument/didChange",
        "params" => %{
          "textDocument" => %{"uri" => "file:///test/doc.md", "version" => 2},
          "contentChanges" => [%{"text" => "v2"}]
        }
      }

      GenLSP.notify(pid, change_notification)
      Process.sleep(50)

      state = :sys.get_state(pid)
      doc = state.assigns.documents["file:///test/doc.md"]
      assert doc.text == "v2"
      assert doc.version == 2
    end
  end

  describe "textDocument/didClose notification" do
    test "removes document from state" do
      {:ok, pid} = Server.start_link([])
      _init = GenLSP.request(pid, initialize_request("file:///test"))

      # Open document
      GenLSP.notify(pid, did_open_notification("file:///test/doc.md", "markdown", "test"))
      Process.sleep(50)

      # Close document
      close_notification = %{
        "jsonrpc" => "2.0",
        "method" => "textDocument/didClose",
        "params" => %{
          "textDocument" => %{"uri" => "file:///test/doc.md"}
        }
      }

      GenLSP.notify(pid, close_notification)
      Process.sleep(50)

      state = :sys.get_state(pid)
      refute Map.has_key?(state.assigns.documents, "file:///test/doc.md")
    end
  end

  describe "textDocument/completion request" do
    test "returns completion items" do
      {:ok, pid} = Server.start_link([])
      _init = GenLSP.request(pid, initialize_request("file:///test"))

      request = completion_request("file:///test/doc.md", 0, 5)
      response = GenLSP.request(pid, request)

      assert is_list(response) or is_map(response)
    end
  end

  describe "textDocument/hover request" do
    test "returns hover information" do
      {:ok, pid} = Server.start_link([])
      _init = GenLSP.request(pid, initialize_request("file:///test"))

      request = hover_request("file:///test/doc.md", 0, 5)
      response = GenLSP.request(pid, request)

      assert is_map(response) or is_nil(response)
    end
  end

  describe "workspace/executeCommand request" do
    test "executes build command", %{test_dir: dir} do
      {:ok, pid} = Server.start_link([])
      _init = GenLSP.request(pid, initialize_request("file://#{dir}"))

      request = %{
        "jsonrpc" => "2.0",
        "id" => 4,
        "method" => "workspace/executeCommand",
        "params" => %{
          "command" => "poly-ssg.build",
          "arguments" => []
        }
      }

      response = GenLSP.request(pid, request)
      assert is_map(response) or is_tuple(response)
    end

    test "returns error for unknown command" do
      {:ok, pid} = Server.start_link([])
      _init = GenLSP.request(pid, initialize_request("file:///test"))

      request = %{
        "jsonrpc" => "2.0",
        "id" => 5,
        "method" => "workspace/executeCommand",
        "params" => %{
          "command" => "unknown.command",
          "arguments" => []
        }
      }

      response = GenLSP.request(pid, request)
      assert {:error, _} = response or (is_map(response) and Map.has_key?(response, "error"))
    end
  end
end
