"use strict";
// SPDX-License-Identifier: PMPL-1.0-or-later
// SPDX-FileCopyrightText: 2025 Jonathan D.A. Jewell <jonathan.jewell@open.ac.uk>
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.activate = activate;
exports.deactivate = deactivate;
const path = __importStar(require("path"));
const vscode = __importStar(require("vscode"));
const node_1 = require("vscode-languageclient/node");
let client;
function activate(context) {
    console.log('PolySSG extension activated');
    // Get configuration
    const config = vscode.workspace.getConfiguration('poly-ssg');
    const customPath = config.get('lsp.path');
    const args = config.get('lsp.args', []);
    // Server options
    const serverOptions = {
        command: customPath || 'mix',
        args: customPath ? args : ['run', '--no-halt'],
        options: {
            cwd: customPath ? path.dirname(customPath) : undefined
        }
    };
    // Client options
    const clientOptions = {
        // Register the server for markdown, TOML, YAML files
        documentSelector: [
            { scheme: 'file', language: 'markdown' },
            { scheme: 'file', language: 'toml' },
            { scheme: 'file', language: 'yaml' }
        ],
        synchronize: {
            // Notify the server about file changes to SSG config files
            fileEvents: vscode.workspace.createFileSystemWatcher('**/{config.toml,config.yaml,_config.yml,book.toml,config.md,site.hs}')
        }
    };
    // Create the language client
    client = new node_1.LanguageClient('poly-ssg', 'PolySSG Language Server', serverOptions, clientOptions);
    // Register commands
    context.subscriptions.push(vscode.commands.registerCommand('poly-ssg.build', async () => {
        await client.sendRequest('workspace/executeCommand', {
            command: 'poly-ssg.build',
            arguments: []
        });
        vscode.window.showInformationMessage('Building site...');
    }));
    context.subscriptions.push(vscode.commands.registerCommand('poly-ssg.serve', async () => {
        const result = await client.sendRequest('workspace/executeCommand', {
            command: 'poly-ssg.serve',
            arguments: []
        });
        vscode.window.showInformationMessage(`Dev server started on port ${result.port || 'unknown'}`);
    }));
    context.subscriptions.push(vscode.commands.registerCommand('poly-ssg.clean', async () => {
        await client.sendRequest('workspace/executeCommand', {
            command: 'poly-ssg.clean',
            arguments: []
        });
        vscode.window.showInformationMessage('Build artifacts cleaned');
    }));
    context.subscriptions.push(vscode.commands.registerCommand('poly-ssg.restartServer', async () => {
        await client.stop();
        await client.start();
        vscode.window.showInformationMessage('LSP server restarted');
    }));
    // Start the client (this will also launch the server)
    client.start();
}
function deactivate() {
    if (!client) {
        return undefined;
    }
    return client.stop();
}
//# sourceMappingURL=extension.js.map