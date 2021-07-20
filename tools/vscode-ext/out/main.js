var __commonJS = (cb, mod) => function __require() {
  return mod || (0, cb[Object.keys(cb)[0]])((mod = { exports: {} }).exports, mod), mod.exports;
};

// src/mnemonics.js
var require_mnemonics = __commonJS({
  "src/mnemonics.js"() {
    modules.export = [
      {
        name: "add",
        desc: "",
        argc: 0,
        input0: "pop",
        input1: "pop",
        output: "push",
        command: "add",
        flags: false,
        condition: "always"
      },
      {
        name: "asl",
        desc: "",
        argc: 0,
        input0: "pop",
        input1: "zero",
        output: "push",
        command: "lsl",
        flags: false,
        condition: "always"
      },
      {
        name: "asr",
        desc: "",
        argc: 0,
        input0: "pop",
        input1: "zero",
        output: "push",
        command: "asr",
        flags: false,
        condition: "always"
      },
      {
        name: "bpget",
        desc: "",
        argc: 0,
        input0: "zero",
        input1: "zero",
        output: "push",
        command: "bpget",
        flags: false,
        condition: "always"
      },
      {
        name: "bpset",
        desc: "",
        argc: 0,
        input0: "pop",
        input1: "zero",
        output: "discard",
        command: "bpset",
        flags: false,
        condition: "always"
      },
      {
        name: "bswap",
        desc: "Swaps bytes of stack top",
        argc: 0,
        input0: "pop",
        input1: "zero",
        output: "push",
        command: "bswap",
        flags: false,
        condition: "always"
      },
      {
        name: "call",
        desc: "Pops address and calls it.",
        argc: 0,
        input0: "pop",
        input1: "zero",
        output: "push",
        command: "setip",
        flags: false,
        condition: "always"
      },
      {
        name: "cmp",
        desc: "Compares two values from the stack.",
        argc: 0,
        input0: "pop",
        input1: "pop",
        output: "discard",
        command: "sub",
        flags: true,
        condition: "always"
      },
      {
        name: "cmp",
        desc: "Compares stack top to immediate value",
        argc: 1,
        input0: "pop",
        input1: "immediate",
        output: "discard",
        command: "sub",
        flags: true,
        condition: "always"
      },
      {
        name: "div",
        desc: "",
        argc: 0,
        input0: "pop",
        input1: "pop",
        output: "push",
        command: "div",
        flags: false,
        condition: "always"
      },
      {
        name: "dup",
        desc: "Duplicates the stack top",
        argc: 0,
        input0: "peek",
        input1: "zero",
        output: "push",
        command: "copy",
        flags: false,
        condition: "always"
      },
      {
        name: "frget",
        desc: "",
        argc: 0,
        input0: "zero",
        input1: "zero",
        output: "push",
        command: "frget",
        flags: false,
        condition: "always"
      },
      {
        name: "frset",
        desc: "",
        argc: 0,
        input0: "pop",
        input1: "zero",
        output: "discard",
        command: "frset",
        flags: false,
        condition: "always"
      },
      {
        name: "intr",
        desc: "Invokes the given interrupts.",
        argc: 1,
        input0: "immediate",
        input1: "zero",
        output: "discard",
        command: "intr",
        flags: false,
        condition: "always"
      },
      {
        name: "iret",
        desc: "Returns from a interrupt.",
        argc: 0,
        input0: "pop",
        input1: "pop",
        output: "discard",
        command: "setip",
        flags: false,
        condition: "always"
      },
      {
        name: "lsl",
        desc: "",
        argc: 0,
        input0: "pop",
        input1: "zero",
        output: "push",
        command: "lsl",
        flags: false,
        condition: "always"
      },
      {
        name: "lsr",
        desc: "",
        argc: 0,
        input0: "pop",
        input1: "zero",
        output: "push",
        command: "lsr",
        flags: false,
        condition: "always"
      },
      {
        name: "mod",
        desc: "",
        argc: 0,
        input0: "pop",
        input1: "pop",
        output: "push",
        command: "mod",
        flags: false,
        condition: "always"
      },
      {
        name: "mul",
        desc: "",
        argc: 0,
        input0: "pop",
        input1: "pop",
        output: "push",
        command: "mul",
        flags: false,
        condition: "always"
      },
      {
        name: "ret",
        desc: "Returns from a function call.",
        argc: 0,
        input0: "pop",
        input1: "zero",
        output: "discard",
        command: "setip",
        flags: false,
        condition: "always"
      },
      {
        name: "call",
        desc: "Calls immediate address.",
        argc: 1,
        input0: "immediate",
        input1: "zero",
        output: "push",
        command: "setip",
        flags: false,
        condition: "always"
      },
      {
        name: "jmp",
        desc: "Pops address, jumps to it.",
        argc: 0,
        input0: "pop",
        input1: "zero",
        output: "discard",
        command: "setip",
        flags: false,
        condition: "always"
      },
      {
        name: "ror",
        desc: "",
        argc: 0,
        input0: "pop",
        input1: "zero",
        output: "push",
        command: "ror",
        flags: false,
        condition: "always"
      },
      {
        name: "sgnext",
        desc: "Sign-extends stack top.",
        argc: 0,
        input0: "pop",
        input1: "zero",
        output: "push",
        command: "signext",
        flags: false,
        condition: "always"
      },
      {
        name: "cmpp",
        desc: "Compares stack top to immediate value, doesn't pop.",
        argc: 1,
        input0: "peek",
        input1: "immediate",
        output: "discard",
        command: "sub",
        flags: true,
        condition: "always"
      },
      {
        name: "jmp",
        desc: "Jumps to immediate address.",
        argc: 1,
        input0: "immediate",
        input1: "zero",
        output: "discard",
        command: "setip",
        flags: false,
        condition: "always"
      },
      {
        name: "neg",
        desc: "",
        argc: 0,
        input0: "zero",
        input1: "pop",
        output: "push",
        command: "sub",
        flags: false,
        condition: "always"
      },
      {
        name: "not",
        desc: "",
        argc: 0,
        input0: "pop",
        input1: "zero",
        output: "push",
        command: "not",
        flags: false,
        condition: "always"
      },
      {
        name: "add",
        desc: "Adds immediate to stack top.",
        argc: 1,
        input0: "pop",
        input1: "immediate",
        output: "push",
        command: "add",
        flags: false,
        condition: "always"
      },
      {
        name: "and",
        desc: "",
        argc: 0,
        input0: "pop",
        input1: "pop",
        output: "push",
        command: "and",
        flags: false,
        condition: "always"
      },
      {
        name: "and",
        desc: "",
        argc: 1,
        input0: "pop",
        input1: "immediate",
        output: "push",
        command: "and",
        flags: false,
        condition: "always"
      },
      {
        name: "div",
        desc: "Divides stack top by immediate.",
        argc: 1,
        input0: "pop",
        input1: "immediate",
        output: "push",
        command: "div",
        flags: false,
        condition: "always"
      },
      {
        name: "mod",
        desc: "Computes modulus of stack top % immediate",
        argc: 1,
        input0: "pop",
        input1: "immediate",
        output: "push",
        command: "mod",
        flags: false,
        condition: "always"
      },
      {
        name: "mul",
        desc: "Multiplies immediate and stack top.",
        argc: 1,
        input0: "pop",
        input1: "immediate",
        output: "push",
        command: "mul",
        flags: false,
        condition: "always"
      },
      {
        name: "or",
        desc: "",
        argc: 0,
        input0: "pop",
        input1: "pop",
        output: "push",
        command: "or",
        flags: false,
        condition: "always"
      },
      {
        name: "or",
        desc: "",
        argc: 1,
        input0: "pop",
        input1: "immediate",
        output: "push",
        command: "or",
        flags: false,
        condition: "always"
      },
      {
        name: "rol",
        desc: "",
        argc: 0,
        input0: "pop",
        input1: "zero",
        output: "push",
        command: "rol",
        flags: false,
        condition: "always"
      },
      {
        name: "sub",
        desc: "",
        argc: 0,
        input0: "pop",
        input1: "pop",
        output: "push",
        command: "sub",
        flags: false,
        condition: "always"
      },
      {
        name: "xor",
        desc: "",
        argc: 0,
        input0: "pop",
        input1: "pop",
        output: "push",
        command: "xor",
        flags: false,
        condition: "always"
      },
      {
        name: "and",
        desc: "",
        argc: 1,
        input0: "pop",
        input1: "immediate",
        output: "push",
        command: "and",
        flags: false,
        condition: "always"
      },
      {
        name: "bpset",
        desc: "",
        argc: 1,
        input0: "immediate",
        input1: "zero",
        output: "discard",
        command: "bpset",
        flags: false,
        condition: "always"
      },
      {
        name: "frset",
        desc: "",
        argc: 1,
        input0: "immediate",
        input1: "zero",
        output: "discard",
        command: "frset",
        flags: false,
        condition: "always"
      },
      {
        name: "or",
        desc: "",
        argc: 1,
        input0: "pop",
        input1: "immediate",
        output: "push",
        command: "or",
        flags: false,
        condition: "always"
      },
      {
        name: "sub",
        desc: "Subtracts immediate from stack top.",
        argc: 1,
        input0: "pop",
        input1: "immediate",
        output: "push",
        command: "sub",
        flags: false,
        condition: "always"
      },
      {
        name: "xor",
        desc: "",
        argc: 1,
        input0: "pop",
        input1: "immediate",
        output: "push",
        command: "xor",
        flags: false,
        condition: "always"
      },
      {
        name: "xor",
        desc: "",
        argc: 1,
        input0: "pop",
        input1: "immediate",
        output: "push",
        command: "xor",
        flags: false,
        condition: "always"
      },
      {
        name: "frset",
        desc: "",
        argc: 2,
        input0: "immediate",
        input1: "immediate",
        output: "discard",
        command: "frset",
        flags: false,
        condition: "always"
      },
      {
        name: "get",
        desc: "",
        argc: 0,
        input0: "pop",
        input1: "zero",
        output: "push",
        command: "get",
        flags: false,
        condition: "always"
      },
      {
        name: "set",
        desc: "",
        argc: 0,
        input0: "pop",
        input1: "pop",
        output: "discard",
        command: "set",
        flags: false,
        condition: "always"
      },
      {
        name: "spget",
        desc: "",
        argc: 0,
        input0: "zero",
        input1: "zero",
        output: "push",
        command: "spget",
        flags: false,
        condition: "always"
      },
      {
        name: "spset",
        desc: "",
        argc: 0,
        input0: "pop",
        input1: "zero",
        output: "discard",
        command: "spset",
        flags: false,
        condition: "always"
      },
      {
        name: "get",
        desc: "",
        argc: 1,
        input0: "immediate",
        input1: "zero",
        output: "push",
        command: "get",
        flags: false,
        condition: "always"
      },
      {
        name: "ld",
        desc: "Pops address, pushes word at address",
        argc: 0,
        input0: "pop",
        input1: "zero",
        output: "push",
        command: "load16",
        flags: false,
        condition: "always"
      },
      {
        name: "ld8",
        desc: "Pops address, pushes byte at address",
        argc: 0,
        input0: "pop",
        input1: "zero",
        output: "push",
        command: "load8",
        flags: false,
        condition: "always"
      },
      {
        name: "ld",
        desc: "Pushes the word from the immediate address",
        argc: 1,
        input0: "immediate",
        input1: "zero",
        output: "push",
        command: "load16",
        flags: false,
        condition: "always"
      },
      {
        name: "ld8",
        desc: "Pushes the byte from the immediate address",
        argc: 1,
        input0: "immediate",
        input1: "zero",
        output: "push",
        command: "load8",
        flags: false,
        condition: "always"
      },
      {
        name: "nop",
        desc: "Does nothing",
        argc: 0,
        input0: "zero",
        input1: "zero",
        output: "discard",
        command: "copy",
        flags: false,
        condition: "always"
      },
      {
        name: "pop",
        desc: "Removes the stack top",
        argc: 0,
        input0: "pop",
        input1: "zero",
        output: "discard",
        command: "copy",
        flags: false,
        condition: "always"
      },
      {
        name: "push",
        desc: "Pushes a value",
        argc: 1,
        input0: "immediate",
        input1: "zero",
        output: "push",
        command: "copy",
        flags: false,
        condition: "always"
      },
      {
        name: "replace",
        desc: "Removes the stack top and pushes a value",
        argc: 1,
        input0: "immediate",
        input1: "pop",
        output: "push",
        command: "copy",
        flags: false,
        condition: "always"
      },
      {
        name: "set",
        desc: "",
        argc: 1,
        input0: "immediate",
        input1: "pop",
        output: "discard",
        command: "set",
        flags: false,
        condition: "always"
      },
      {
        name: "spset",
        desc: "",
        argc: 1,
        input0: "immediate",
        input1: "zero",
        output: "discard",
        command: "spset",
        flags: false,
        condition: "always"
      },
      {
        name: "st",
        desc: "Pops word and address, stores it.",
        argc: 0,
        input0: "pop",
        input1: "pop",
        output: "discard",
        command: "store16",
        flags: false,
        condition: "always"
      },
      {
        name: "st8",
        desc: "Pops byte and address, stores it.",
        argc: 0,
        input0: "pop",
        input1: "pop",
        output: "discard",
        command: "store8",
        flags: false,
        condition: "always"
      },
      {
        name: "st",
        desc: "Pops a word and stores it at the immediate address",
        argc: 1,
        input0: "pop",
        input1: "immediate",
        output: "discard",
        command: "store16",
        flags: false,
        condition: "always"
      },
      {
        name: "st",
        desc: "Stores immediate word at immediate address.",
        argc: 2,
        input0: "immediate",
        input1: "immediate",
        output: "discard",
        command: "store16",
        flags: false,
        condition: "always"
      },
      {
        name: "st8",
        desc: "Pops a byte and stores it at the immediate address",
        argc: 1,
        input0: "pop",
        input1: "immediate",
        output: "discard",
        command: "store8",
        flags: false,
        condition: "always"
      },
      {
        name: "st8",
        desc: "Stores immediate byte at immediate address.",
        argc: 2,
        input0: "immediate",
        input1: "immediate",
        output: "discard",
        command: "store8",
        flags: false,
        condition: "always"
      }
    ];
  }
});

// src/extension.js
var vscode = require("vscode");
var mnemonics = require_mnemonics();
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
  let disposable = vscode.commands.registerCommand("spumk2.helloWorld", function() {
    vscode.window.showInformationMessage("This is a example command!");
  });
  let hoverprovider = vscode.languages.registerHoverProvider("spumk2.asm", {
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
        str += `| command   | **${m.command}**   |
`;
        str += "|-----------|--------------------|\n";
        str += `| input 0   | **${m.input0}**    |
`;
        str += `| input 1   | **${m.input1}**    |
`;
        str += `| output    | **${m.output}**    |
`;
        str += `| flags     | **${m.flags}**     |
`;
        str += `| condition | **${m.condition}** |
`;
        text.appendMarkdown(str + "\n\n");
      }
      if (text.value.length == 0)
        return;
      return new vscode.Hover(text);
    }
  });
  const label_match = /^(\w[\w\.]+):/;
  let autocompleter = vscode.languages.registerCompletionItemProvider("spumk2.asm", {
    provideCompletionItems(document, position, token, context2) {
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
        comp.insertText = new vscode.SnippetString(mnemonicPreview(m, (i2) => "${" + String(i2 + 1) + ":imm}"));
        comp.documentation = new vscode.MarkdownString(m.desc);
        completions.push(comp);
      }
      return completions;
    }
  });
  let defprovider = vscode.languages.registerDefinitionProvider("spumk2.asm", {
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
function deactivate() {
}
module.exports = {
  activate,
  deactivate
};
//# sourceMappingURL=main.js.map
