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

var emulation_running = false;

function setEnabled(ui, enabled) {
    if (enabled) {
        ui.removeAttribute("disabled");
    } else {
        ui.setAttribute("disabled", "");
    }
}

function updateUI() {
    const emulator_load = document.getElementById('emulator-load');
    const emulator_reset = document.getElementById('emulator-reset');
    const emulator_nmi = document.getElementById('emulator-nmi');
    const emulator_start = document.getElementById('emulator-start');
    const emulator_stop = document.getElementById('emulator-stop');
    const emulator_step = document.getElementById('emulator-step');

    setEnabled(emulator_load, !emulation_running);
    setEnabled(emulator_reset, true);
    setEnabled(emulator_nmi, true);
    setEnabled(emulator_start, !emulation_running);
    setEnabled(emulator_stop, emulation_running);
    setEnabled(emulator_step, !emulation_running);
}

function emulateFor(num) {
    const success = wasmContext.instance.exports.run(num);
    if (success != 0) {
        emulation_running = false;
        console.log('emulator failed: ', translateEmulatorError(success));
    }
    return success;
}

function stepEmulator(time) {
    if (emulateFor(4096) != 0) {
        emulation_running = false;
        updateUI();
        return;
    }
    if (emulation_running) {
        window.requestAnimationFrame(stepEmulator);
    }
}

function pauseEmulation() {
    emulation_running = false;
    updateUI();
}

function startEmulation() {
    if (!emulation_running) {
        emulation_running = true;
        window.requestAnimationFrame(stepEmulator);
    }
    updateUI();
}

function tickEmulation() {
    if (!emulation_running) {
        emulateFor(1);
        updateUI();
    }
}

function invokeReset() {
    wasmContext.instance.exports.resetCpu();
}

function invokeNmi() {
    wasmContext.instance.exports.invokeNmi();
}


function hexDump() {
    let rom_view = new Uint8Array(
        wasmContext.instance.exports.memory.buffer,
        wasmContext.instance.exports.getMemoryPtr(),
        65536);
    let was_zero = false;
    let i = 0;
    while (i < 65536) {
        const view = rom_view.slice(i, i + 16);
        const arr = Array.from(view);
        const is_zero = arr.every(x => (x == 0));

        if ((is_zero && !was_zero) || !is_zero) {
            console.log(
                i.toString(16).padStart(4, "0"),
                arr.map(x => x.toString(16).padStart(2, "0")).join(" "));
        }

        was_zero = is_zero;
        i += 16;
    }
}

function loadFile(file) {
    if (emulation_running) {
        throw 'Cannot load file while running!';
    }

    var reader = new FileReader();
    reader.onload = function(e) {
        if (emulation_running) {
            throw 'Cannot load file while running!';
        }

        var file_view = new Uint8Array(e.target.result);

        let rom_view = new Uint8Array(
            wasmContext.instance.exports.memory.buffer,
            wasmContext.instance.exports.getMemoryPtr(),
            65536);

        let len = Math.min(file_view.length, rom_view.length);

        let i = 0;
        while (i < len) {
            rom_view[i] = file_view[i];
            i += 1;
        }

        console.log("Loaded ", len, " bytes into rom!");

        invokeReset();
    };
    let buffer = reader.readAsArrayBuffer(file);
}

let file_select = document.getElementById("emulator-file-select");

function beginUserSelectFile() {
    file_select.click();
}

fetch('emulator.wasm')
    .then(response => response.arrayBuffer())
    .then(bytes => WebAssembly.instantiate(bytes, wasmImports))
    .then(results => {
        wasmContext.instance = results.instance;

        results.instance.exports.init();

        startEmulation();


        file_select.addEventListener('change', function(ea) {
            var file = ea.target.files[0];
            if (!file) {
                return;
            }
            loadFile(file);
        }, false);
    });

term.onData(data => wasmContext.inputBuffer += data);
term.focus();