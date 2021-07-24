var term = new Terminal();
term.open(document.getElementById('live-terminal'));

function $(pat) {
    const x = document.querySelector(pat);
    if (x === null) throw 'could not find ' + pat;
    return x;
}

var wasmContext = {
    instance: null,
    inputBuffer: '',
};

const wasmImports = {
    env: {
        serialRead(data, len) {
            let byteView =
                new Uint8Array(wasmContext.instance.exports.memory.buffer, data, len);

            let i = 0;
            while (wasmContext.inputBuffer.length > 0 && i < len) {
                const c = wasmContext.inputBuffer.charCodeAt(0);

                byteView[i] = c;

                i += 1;
                wasmContext.inputBuffer = wasmContext.inputBuffer.substr(1);
            }

            return i;
        },
        serialWrite(data, len) {
            const decoder = new TextDecoder('utf-8');

            let byteView =
                new Uint8Array(wasmContext.instance.exports.memory.buffer, data, len);

            let s = decoder.decode(byteView);

            term.write(s);
        },
        invokeJsPanic() {
            throw 'wasm panic';
        },
    }
};

function translateEmulatorError(ind) {
    switch (ind) {
        case 0:
            return 'success';
        case 1:
            return 'bad instruction';
        case 2:
            return 'unaligned access';
        case 3:
            return 'bus error';
        default:
            return 'unknown';
    }
}

function stepEmulator(time) {
    const success = wasmContext.instance.exports.run(4096);
    if (success == 0) {
        window.requestAnimationFrame(stepEmulator);
    } else {
        console.log('emulator failed: ', translateEmulatorError(success));
    }
}

fetch('emulator.wasm')
    .then(response => response.arrayBuffer())
    .then(bytes => WebAssembly.instantiate(bytes, wasmImports))
    .then(results => {
        wasmContext.instance = results.instance;

        results.instance.exports.init();

        window.requestAnimationFrame(stepEmulator);
    });


term.onData(data => wasmContext.inputBuffer += data);
term.focus();