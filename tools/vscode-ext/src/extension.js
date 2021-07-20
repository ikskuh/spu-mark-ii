const vscode = require('vscode');

const mnemonics = require("./mnemonics.js");

function mnemonicPreview(m, f) {
    var str = m.name;
    for (var i = 0; i < m.argc; i++) {
        if (i > 0)
            str += ", ";
        else
            str += " ";
        if (f) {
            str += f(i);
        } else {
            str += "imm";
        }
    }
    return str;
}

function activate(context) {
    // The command has been defined in the package.json file
    // Now provide the implementation of the command with  registerCommand
    // The commandId parameter must match the command field in package.json
    let disposable = vscode.commands.registerCommand('spumk2.helloWorld', function() {
        vscode.window.showInformationMessage('This is a example command!');
    });

    let hoverprovider = vscode.languages.registerHoverProvider('spumk2.asm', {
        provideHover(document, position, token) {
            const word_range = document.getWordRangeAtPosition(position);

            if (word_range === null)
                return;

            const word = document.getText(word_range);
            if (word === null)
                return;

            const text = new vscode.MarkdownString();
            text.isTrusted = true;

            for (var m of mnemonics) {
                if (m.name !== word)
                    continue;
                var str = `**${m.name}** `;
                for (var i = 0; i < m.argc; i++) {
                    if (i > 0)
                        str += ", ";
                    str += "imm";
                }
                str += "  \n\n";
                str += `| command   | **${m.command}**   |\n`;
                str += "|-----------|--------------------|\n";
                str += `| input 0   | **${m.input0}**    |\n`;
                str += `| input 1   | **${m.input1}**    |\n`;
                str += `| output    | **${m.output}**    |\n`;
                str += `| flags     | **${m.flags}**     |\n`;
                str += `| condition | **${m.condition}** |\n`;
                text.appendMarkdown(str + "\n\n");
            }

            if (text.value.length == 0)
                return;

            return new vscode.Hover(text);
        }
    });

    const label_match = /^(\w[\w\.]+):/;

    let autocompleter = vscode.languages.registerCompletionItemProvider('spumk2.asm', {

        // TODO: Implement improved auto-completions
        // trigger on `[..for possible modifiers
        // trigger on `[..:` for possible modifier values
        // trigger on line start for mnemonics
        // trigger after mnemonics for symbols/label names
        provideCompletionItems(document, position, token, context) {
            // console.log("completion", document, position, token, context, document.lineAt(position.line));

            let completions = [];
            for (var i = 0; i < document.lineCount; i++) {
                const line = document.lineAt(i).text;
                const match = line.match(label_match);
                if (match !== null) {
                    completions.push(new vscode.CompletionItem(match[1]));
                }
            }

            for (var m of mnemonics) {
                let comp = new vscode.CompletionItem();
                comp.label = mnemonicPreview(m);
                comp.insertText = new vscode.SnippetString(mnemonicPreview(m, (i) => "${" + String(i + 1) + ":imm}"));
                comp.documentation = new vscode.MarkdownString(m.desc);
                completions.push(comp);
            }

            return completions;
        }
    });

    let defprovider = vscode.languages.registerDefinitionProvider('spumk2.asm', {
        // TODO: Allow go-to into other .include files
        provideDefinition(document, position, token) {
            const word_range = document.getWordRangeAtPosition(position);

            if (word_range === null)
                return;

            const word = document.getText(word_range);
            if (word === null)
                return;

            for (var i = 0; i < document.lineCount; i++) {
                const line = document.lineAt(i);
                const match = line.text.match(label_match);
                if (match !== null) {
                    if (match[1] === word) {
                        return new vscode.Location(document.uri, line.range.start);
                    }
                }
            }
        }
    });

    context.subscriptions.push(disposable);
    context.subscriptions.push(hoverprovider);
    context.subscriptions.push(autocompleter);
    context.subscriptions.push(defprovider);

    console.log("spumk2 ready.");
}

function deactivate() {}

module.exports = {
    activate,
    deactivate
}