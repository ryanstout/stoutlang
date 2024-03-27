const vscode = require('vscode'); // Ensure vscode is required at the top
const { LanguageClient } = require('vscode-languageclient');

let languageClient;

function activate(context) {
    // Create an output channel for logging
    const outputChannel = vscode.window.createOutputChannel('StoutLang Server Logs');
    outputChannel.appendLine('Starting StoutLang language server1');

    let serverOptions = {
        command: 'ruby', args: [`${__dirname}/src/ruby_lsp_server.rb`],
    };
    

    let clientOptions = {
        documentSelector: [{ scheme: 'file', language: 'stoutlang' }],
        // synchronize: {
        //     fileEvents: vscode.workspace.createFileSystemWatcher('**/.clientrc')
        // },
        outputChannel: outputChannel,
    };

    // Initialize the language client but don't start it yet
    languageClient = new LanguageClient(
        'stoutlang',
        'StoutLang Server',
        serverOptions,
        clientOptions
    );

    outputChannel.appendLine('Started server');

    // Start the language client and add it to the context's subscriptions
    let disposable = languageClient.start();
    context.subscriptions.push(disposable);

    outputChannel.show(true);
}

function deactivate() {
    if (!languageClient) {
        return undefined;
    }
    // Stop the language client and thus the language server
    return languageClient.stop();
}

exports.activate = activate;
exports.deactivate = deactivate;
