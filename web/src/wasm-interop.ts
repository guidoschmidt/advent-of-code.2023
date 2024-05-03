export const runWasmModule = async (day: number) => {
  const module = await import(`./wasm/aoc_day-${day}.wasm?url`);
  const wasmUrl = module.default;

  const textDecoder = new TextDecoder();
  const textEncoder = new TextEncoder();
  let memory = undefined;

  const imports = {
    wasmapi: {
      logUsize: (x) => console.log(x),
      logU32: (x) => console.log(x),
      logStr: (addr, len) => {
        const str = textDecoder.decode(
          new Uint8Array(memory.buffer, addr, len),
        );
        console.log(str);
      },
    },
  };
  const { instance } = await WebAssembly.instantiateStreaming(
    fetch(wasmUrl),
    imports,
  );
  console.log(instance);
  const { allocUint8, part1_wasm, part2_wasm } = instance.exports;
  memory = instance.exports.memory;

  const fetchInputRes = await fetch(`./day${day}.txt`);
  let fetchInput = await fetchInputRes.text();
  fetchInput = fetchInput.replaceAll("\r\n", "\n");

  const inputBuffer = textEncoder.encode(fetchInput);
  const inputPtr = allocUint8(inputBuffer.length + 1);
  const slice = new Uint8Array(memory.buffer, inputPtr, inputBuffer.length + 1);
  slice.set(inputBuffer);
  slice[inputBuffer.length] = 0; // null byte to null-terminate the string

  const result_part1 = part1_wasm(inputPtr, inputBuffer.length + 1);
  const result_part2 = part2_wasm(inputPtr, inputBuffer.length + 1);
};
