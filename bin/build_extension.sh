#!/bin/bash

cd lsp/vscode/sl ; vsce package
code --install-extension sl-*.vsix