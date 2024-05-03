import {} from "@thi.ng/rstream";
import { $compile, $list } from "@thi.ng/rdom";
import { reactive } from "@thi.ng/rstream";
import { range } from "@thi.ng/transducers";
import { TestClass } from "./TestClass";
import { runWasmModule } from "./wasm-interop";

$compile([
  "div",
  {},
  ["h1", {}, "Advent of Code 2023"],
  ["h2", {}, "zig + wasm"],
  $list(reactive([...range(1, 25)]), "div", {}, (x) => [
    "button",
    {
      onclick: () => {
        runWasmModule(x);
      },
    },
    x,
  ]),
]).mount(document.body);

globalThis.getPatchedTouchpoint = () => ({ width: 2, height: 2 });

const origInit = TestClass.prototype.init;
TestClass.prototype.init = () => {
  const patched = origInit
    .toString()
    .split("\n")
    .map((line) => {
      if (line.includes("getTouchpoint")) {
        line = line.replace(
          "getTouchpoint()",
          "globalThis.getPatchedTouchpoint()",
        );
      }
      return line;
    })
    .slice(1, -1)
    .join("\n");
  const f = new Function(patched);
  f();
};

new TestClass();
